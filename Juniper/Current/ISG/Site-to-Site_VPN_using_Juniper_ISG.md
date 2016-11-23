This configuration template applies to **Juniper ISG 1000** Integrated Security Gateway running ScreenOS 6.3. It configures an IPSec VPN tunnel connecting your on-premise VPN device with the Azure gateway.

-----------
In example:

- Vpn Type: **RouteBased**
- Local virtual network gateway Ip Address: **206.X.X.X** (J Series external interface IP or Public IP address) 
- Local Network Prefix: **192.168.1.0/24** (Your on-premises local network. Specify starting IP address of your network.) 
- Azure VNet Network Prefix: **10.0.0.0/8** (Azure virtual network) 
- Azure Gateway IP: **40.76.X.X**
- Shared Key: **879ac96b53764ad0b6482e55c0e05a0a**

-----------

### Virtual tunnel interface configuration ###

	set interface tunnel.1 zone untrust
	set interface tunnel.1 ip unnumbered interface <NameOfYourOutsideInterface>
	set route 10.0.0.0/8 interface tunnel.1

### Internet Key Exchange (IKE) configuration ###

This section specifies the authentication, encryption, hashing, and lifetime parameters for the Phase 1 negotiation and the main mode security association. We also specify the IP address of the peer of your on-premise VPN device (which is the Azure Gateway) here.

	set ike gateway ikev2 azure-gateway address 40.76.X.X outgoing-interface <NameOfYourOutsideInterface> preshare 879ac96b53764ad0b6482e55c0e05a0a sec-level compatible
	set ike gateway azure-gateway dpd-liveness interval 10

### IPSec configuration ###

This section specifies encryption, authentication, and lifetime properties for the Phase 2 negotiation and the quick mode security association. We also bind the IPSec policy to the virtual tunnel interface, through which cross-premise traffic will be transmitted.

	set vpn azure-ipsec-vpn gateway azure-gateway tunnel idletime 0 sec-level compatible
	set vpn azure-ipsec-vpn bind interface tunnel.1

### ACL rules ###

Proper ACL rules are needed for permitting cross-premise network traffic. You should also allow inbound UDP/ESP traffic for the interface which will be used for the IPSec tunnel.

	set address trust onprem-networks-1 192.168.0.0/24
	set address untrust azure-networks-1 10.0.0.0/8
	set policy top from trust to untrust onprem-networks-1 azure-networks-1 any permit
	set policy top from untrust to trust azure-networks-1 onprem-networks-1 any permit

### TCPMSS clamping ###

Adjust the TCPMSS value properly to avoid fragmentation

	set flow vpn-tcp-mss 1350
	save