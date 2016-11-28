# **Configure Azure via JSON template:** #

[![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Fortinet/Images/Deploy.jpg?raw=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-site-to-site-vpn%2Fazuredeploy.json)

[https://github.com/Azure/azure-quickstart-templates/tree/master/201-site-to-site-vpn](https://github.com/Azure/azure-quickstart-templates/tree/master/201-site-to-site-vpn)

In example:

Vpn Type: **RouteBased**

Local virtual network gateway Ip Address: **206.X.X.X** (SRX external interface IP or Public IP address) 

Azure Gateway Public IP Address: **40.x.x.x**

Local Network Prefix: **192.168.1.0/24** (Your on-premises local network. Specify starting IP address of your network.) 

Azure VNet Address: **10.0.0.0/16**

Shared Key: **879ac96b53764ad0b6482e55c0e05a0a**

It takes couple of minutes to create Gateway Connection. Once created review the Virtual Network Gateway IP Address 
![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Juniper/Current/Images/SSG/AzureGW.png?raw=true)

# **Configuring the SSG:** #
Configuring the SSG 
Now we need to configure the SSG. Log into the ScreenOS. One we have logged into ScreenOS CLI we need to see what route can reach the Dynamic Azure Gateway
 
The ScreenOS command is **Get Interface**

![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Juniper/Current/Images/SSG/get_interface.png?raw=true)

In this example eth0/0 is the name of the outgoing-interface, bgroup0 is the name of the bridge group interface
 
The follow script may need to be modified to suit your device

	###Script Begin###
	set interface tunnel.1 zone untrust
	set interface tunnel.1 ip unnumbered interface bgroup0
	set route 10.0.0.0/16 interface tunnel.1
	set ike gateway ikev2 azure-gateway address 40.X.X.X outgoing-interface eth0/0 preshare 879ac96b53764ad0b6482e55c0e05a0a sec-level compatible
	set ike gateway azure-gateway dpd-liveness interval 10
	set vpn azure-ipsec-vpn gateway azure-gateway tunnel idletime 0 sec-level compatible
	set vpn azure-ipsec-vpn bind interface tunnel.1
	set address trust onprem-networks-1 192.168.1.0/24
	set address untrust azure-networks-1 10.0.0.0/16
	set policy top from trust to untrust onprem-networks-1 azure-networks-1 any permit
	set policy top from untrust to trust azure-networks-1 onprem-networks-1 any permit
	set flow vpn-tcp-mss 1350
	save
	###Script End###
	 
	###Script Key###
	bgroup0 is the name of the bridge group interface
	eth0/0 is the name of the outgoing-interface
	40.X.X.X is the IP address of the Dynamic Azure gateway
	879ac96b53764ad0b6482e55c0e05a0a is the Azure Gateway preshared key
	10.0.0.0/16  this is the IP address rage of the azure-networks
	192.168.1.0/24 this is IP address range of the onprem-networks


We will need to use the text typed at the terminal as input to the configuration
 
How to check to see main mode is connected 
 
The ScreenOS command is **Get SA**

![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Juniper/Current/Images/SSG/get_SA.png?raw=true)

[(Both A/- and A/U are positive states that your tunnel is up)](https://kb.juniper.net/InfoCenter/index?page=content&id=KB6134&actp=search)

We can also check the Azure Gateway to view connection

![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Juniper/Current/Images/SSG/AzureGW_connected.png?raw=true)

Reference:

[Get Config](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Juniper/Current/SSG/juniper-ssg-screenos-6.2_get_config.txt)