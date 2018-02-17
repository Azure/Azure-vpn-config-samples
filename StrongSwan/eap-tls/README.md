# Azure VPN gateway with EAP-TLS authentification for Linux based clients

This doc explains how to configure IPsec IKEv2 connection to Azure VPN Gateway with the Azure Certificates authentification method (EAP-TLS).

## Install dependencies

Here are the required packages for Ubuntu:

```sh
apt-get install strongswan-ikev2 strongswan-plugin-eap-tls
# in Ubuntu 16.04 install libstrongswan-standard-plugins for p12 keypair container support
apt-get install libstrongswan-standard-plugins
```

If you install `libstrongswan-extra-plugins` package in Ubuntu 16.04, it will break strongSwan. This package contains `af-alg`, `ctr` and `gcrypt` plugins and they conflict with the `openssl` plugin. In this case you have to either remove the `libstrongswan-standard-plugins` package containing `openssl` plugin, or disable `openssl` plugin:

```sh
sudo sed -i 's/\sload =.*/ load = no/g' /etc/strongswan.d/charon/openssl.conf
```

or `af-alg`, `ctr` and `gcrypt` plugins:

```sh
sudo sed -i 's/\sload =.*/ load = no/g' /etc/strongswan.d/charon/{af-alg,ctr,gcrypt}.conf
```

## Generate keys and certificates

You have to generate your own CA first, then it is necessary to generate user's certificate with the **X509v3 Subject Alternative Name** (SAN) extension ([strongSwan FAQ](https://wiki.strongswan.org/projects/strongswan/wiki/FAQ#Common-Name-field-in-the-Distinguished-Name)), which should correspond to the certificate subject's common name (`CN`). I.e. certificate with the `CN=client` subject must contain `DNS:client` SAN. This will allow you to specify EAP identity without `CN=` prefix in strongSwan. By default strongSwan transfers full certificate subject as EAP identity, but Azure VPN gateway doesn't support that. You can read more about CN vs SAN history: http://unmitigatedrisk.com/?p=381.

```sh
# Generate CA
ipsec pki --gen --outform pem > caKey.pem
ipsec pki --self --in caKey.pem --dn "CN=VPN CA" --ca --outform pem > caCert.pem
# Print CA certificate in base64 format, supported by Azure portal. Will be used later in this document.
openssl x509 -in caCert.pem -outform der | base64 -w0 ; echo

# Generate user's certificate and put it into p12 bundle.
export PASSWORD="password"
export USERNAME="client"
ipsec pki --gen --outform pem > "${USERNAME}Key.pem"
ipsec pki --pub --in "${USERNAME}Key.pem" | ipsec pki --issue --cacert caCert.pem --cakey caKey.pem --dn "CN=${USERNAME}" --san "${USERNAME}" --flag clientAuth --outform pem > "${USERNAME}Cert.pem"
# Generate p12 bundle
openssl pkcs12 -in "${USERNAME}Cert.pem" -inkey "${USERNAME}Key.pem" -certfile caCert.pem -export -out "${USERNAME}.p12" -password "pass:${PASSWORD}"
```

Then open Azure portal, find your "Virtual Network Gateway" and on its **Point-to-site configuration** page in **Root certificates** section paste base64 encoded CA printed above.

## Configure the client

Find **Download VPN client** button on gateway's **Point-to-site configuration** page, then unzip the `VpnServerRoot.cer` CA from the downloaded ZIP archive:

```sh
sudo unzip -j downloaded.zip Generic/VpnServerRoot.cer -d /etc/ipsec.d/cacerts
```

You can verify it using the command below:

```
openssl x509 -inform der -in /etc/ipsec.d/cacerts/VpnServerRoot.cer -text -noout
```

Then extract VPN server DNS:

```sh
$ unzip -p downloaded.zip Generic/VpnSettings.xml | grep VpnServer
  <VpnServer>azuregateway-00112233-4455-6677-8899-aabbccddeeff-aabbccddeeff.cloudapp.net</VpnServer>
```

Use `VpnServer` value for the `right` value and for the `rightid` value prefixed with `%` in `ipsec.conf` below in this doc.

Then copy user's p12 bundle into corresponding directory:

```sh
sudo cp client.p12 /etc/ipsec.d/private/
```

Use the following `/etc/ipsec.conf` configuration:

```sh
config setup

conn azure
  keyexchange=ikev2
  type=tunnel
  leftfirewall=yes
  left=%any
  leftauth=eap-tls
  leftid=%client # use the DNS alternative name prefixed with the %
  right=azuregateway-00112233-4455-6677-8899-aabbccddeeff-aabbccddeeff.cloudapp.net # Azure VPN gateway address
  rightid=%azuregateway-00112233-4455-6677-8899-aabbccddeeff-aabbccddeeff.cloudapp.net # Azure VPN gateway address, prefixed with %
  rightsubnet=0.0.0.0/0
  leftsourceip=%config
  auto=add
```

and `/etc/ipsec.secrets` content:

```
: P12 client.p12 'password' # key filename inside /etc/ipsec.d/private directory
```

Then restart ipsec to reread the configuration and start the tunnel:

```sh
sudo ipsec restart
sudo ipsec up azure
```

### MTU/MSS issue

IPsec VPN client can experience connectivity issues because of high MTU/MSS values and [IKE Fragmentation](https://msdn.microsoft.com/en-us/library/cc233458.aspx). To resolve this issue you have to explicitly set 1350 value for MTU/MSS iside the `kernel-netlink` strongSwan's `charon` configuration (this configuration works only in strongSwan version >= 5.2.1). Set the `mtu` and `mss` values inside the `/etc/strongswan.d/charon/kernel-netlink.conf` configuration file:

```
    mss = 1350
    mtu = 1350
```

and restart the tunnel:

```sh
sudo ipsec restart
sudo ipsec up azure
```

### Verify the status

Print IPsec routes list:

```sh
ip route list table 220
```

Print XFRM policy:

```sh
sudo ip xfrm policy
```

### Notes

Generated certificates work on Android's strongSwan client as well, you have to import server's CA and client's p12 bundle into strongSwan first.

On desktop Linux based OS you can use `ipsec` CLI. EAP-TLS method with the custom EAP identity is not yet supported by the NetworkManager, thus it is not yet possible to configure Azure Point-to-Site VPN connection using GUI. Only PSK method is supported.

Tested strongSwan versions:

* 5.1.2 (Ubuntu 14.04 LTS)
* 5.3.5 (Ubuntu 16.04 LTS)
* 5.6.1 (Ubuntu 18.04 LTS)

Thanks to [@tobiasbrunner](https://github.com/tobiasbrunner) for help.
