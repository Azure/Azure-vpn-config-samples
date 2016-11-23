This configuration template applies to **Juniper J Series** Services Router running JunOS 11.4.x It configures an IPSec VPN tunnel connecting your on-premise VPN device with the Azure gateway.

-----------
In example:

- Vpn Type: **RouteBased**
- Local virtual network gateway Ip Address: **206.X.X.X** (J Series external interface IP or Public IP address) 
- Local Network Prefix: **192.168.1.0/24** (Your on-premises local network. Specify starting IP address of your network.) 
- Azure VNet Network Prefix: **10.0.0.0/8** (Azure virtual network) 
- Azure Gateway IP: **40.76.X.X**
- Shared Key: **879ac96b53764ad0b6482e55c0e05a0a**

-----------



### Internet Key Exchange (IKE) configuration ###

This section specifies the authentication, encryption, hashing, and lifetime parameters for the Phase 1 negotiation and the main mode security association. We also specify the IP address of the peer of your on-premise VPN device (which is the Azure Gateway) here.

	set security ike proposal azure-proposal authentication-method pre-shared-keys
	set security ike proposal azure-proposal authentication-algorithm sha1
	set security ike proposal azure-proposal encryption-algorithm aes-256-cbc
	set security ike proposal azure-proposal lifetime-seconds 10800
	set security ike proposal azure-proposal dh-group group2
	set security ike policy azure-policy mode main
	set security ike policy azure-policy proposals azure-proposal
	set security ike policy azure-policy pre-shared-key ascii-text 879ac96b53764ad0b6482e55c0e05a0a
	set security ike gateway azure-gateway ike-policy azure-policy
	set security ike gateway azure-gateway address 40.76.X.X
	set security ike gateway azure-gateway external-interface <NameOfYourOutsideInterface>
	set security ike gateway azure-gateway version v2-only

### IPSec configuration ###

This section specifies encryption, authentication, and lifetime properties for the Phase 2 negotiation and the quick mode security association.

	set security ipsec proposal azure-ipsec-proposal protocol esp
	set security ipsec proposal azure-ipsec-proposal authentication-algorithm hmac-sha1-96
	set security ipsec proposal azure-ipsec-proposal encryption-algorithm aes-256-cbc
	set security ipsec proposal azure-ipsec-proposal lifetime-seconds 3600
	set security ipsec policy azure-vpn-policy proposals azure-ipsec-proposal
	set security ipsec vpn azure-ipsec-vpn ike gateway azure-gateway
	set security ipsec vpn azure-ipsec-vpn ike ipsec-policy azure-vpn-policy

### ACL rules ###

Proper ACL rules are needed for permitting cross-premise network traffic. You should also allow inbound UDP/ESP traffic for the interface which will be used for the IPSec tunnel.

	set security zones security-zone trust interfaces <NameOfYourInsideInterface>
	set security zones security-zone trust host-inbound-traffic system-services ike
	set security zones security-zone trust address-book address onprem-networks-1 192.168.0.0/24
	set security zones security-zone untrust interfaces <NameOfYourOutsideInterface>
	set security zones security-zone untrust host-inbound-traffic system-services ike
	set security zones security-zone trust address-book address azure-networks-1 10.0.0.0/8

You may need the following line if you have interface specific host-inbound-traffic rule because that will overwrite the zone specific rule

	set security zones security-zone untrust interface <NameOfYourOutsideInterface> host-inbound-traffic system-services ike

### Virtual Tunnel ###

This section creates a new virtual tunnel interface and binds the above-defined IPSec VPN policy to this interface so that the cross-premise network traffic will be properly encrypted and transmitted via the IPSec VPN tunnel

	set interfaces st0 unit 0 family inet
	set security zones security-zone untrust interfaces st0.0
	set security ipsec vpn azure-ipsec-vpn bind-interface st0.0
	set routing-options static route 10.0.0.0/8 next-hop st0.0

### TCPMSS clamping ###
Adjust the TCPMSS value properly to avoid fragmentation

	set security flow tcp-mss ipsec-vpn mss 1350
	commit
	exit