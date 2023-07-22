This configuration template applies to **MikroTik** physical/virtual appliance running **MikroTik RouterOS 6.40.4** or greater. The configuration is probably applicable to older version of RouterOS, but not validated here. It configures an IPSec VPN tunnel connecting your on-premise VPN appliance with the Azure gateway. Things that begin with "azure-" are variable names and can be changed consistently.

- Vpn Type: **RouteBased**
- Local virtual network gateway Ip Address: **131.X.X.X** (Outside Interface IP Address of RouterOS appliance or Public IP address)
- Local Network Prefix: **10.90.0.0/16** (Your on-premises local network. Specify starting IP address of your network.)
- Azure Virtual Network **10.91.0.0/16**
- Shared Key: **a1af0cdcb0494757a16abe0cc2101c7b**

This tutorial is validated on MikroTik Cloud Hosted Router (CHR) on KVM and Microsoft Hyper-V Platform.


### Source NAT Rules ###

Proper NAT rules are needed in order to exchange traffic between Azure Virtual Network and you on-premise network. In this example, **10.90.0.0/16** is the on-premise network and **10.91.0.0/16** is the Azure Virtual Network.

    # Insert the source NAT rule between on-premise gateway and Azure
    # Virtual Network
    /ip firewall nat add chain=srcnat action=accept src-address=10.90.0.0/16 \
    dst-address=10.91.0.0/16

If you have other NAT rules configured, make sure rules are arranged in proper priority. You can check the priority and rearrange rules using following commands:

    # Show all configured rules
    /ip firewall nat print
    # Assume the rule we just added is placed as 7th rule, and we want to move it
    # to the second
    /ip firewall nat move 7 2

### Internet Key Exchange (IKE) and IPSec configuration ###

This section specifies everything needed for our IKEv2 site-to-site VPN connection. In this example the Azure Gateway IP Address is **13.X.X.X**

    # Add new IPSec Proposal (Transform set)
    /ip ipsec proposal add name="azure-ipsec-proposal" auth-algorithms=sha1 \
    enc-algorithms=aes-256-cbc lifetime=2h pfs-group=modp1024

    # Add new IPSec Peer
    /ip ipsec peer add address=13.X.X.X/32 auth-method=pre-shared-key \
    secret="a1af0cdcb0494757a16abe0cc2101c7b" generate-policy=no \
    policy-template-group=default exchange-mode=ike2 send-initial-contact=yes \
    hash-algorithm=sha1 enc-algorithm=aes-256 dh-group=modp1024 \
    lifetime=2h dpd-interval=2m

    # Add a new IPSec Policy
    /ip ipsec policy add src-address=10.90.0.0/16 src-port=any \
    dst-address=10.91.0.0/16 dst-port=any protocol=all action=encrypt \
    level=require ipsec-protocol=esp tunnel=yes sa-src-address=131.X.X.X \
    sa-dst-address=13.X.X.X proposal=azure-ipsec-proposal

### Misc configuration ###

To avoid fragmentation, set TCPMSS to 1350.

    # Set TCPMSS to 1350 (varies depends on your local network configuration)
    /ip firewall mangle add chain=forward action=change-mss new-mss=1350 \
    passthrough=yes tcp-flags=syn protocol=tcp tcp-mss=!0-1350 log=no \
    log-prefix=""

On certain devices (for example, MikroTik hEX) It probably doesn't work. 
In such circumstances, adjust interface MTU might help.