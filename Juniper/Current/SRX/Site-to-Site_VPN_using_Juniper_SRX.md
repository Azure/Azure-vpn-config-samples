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
![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Juniper/Current/Images/SRX/AzureGW.png?raw=true)

# **Configuring the SRX:** #

Now we need to configure the SRX. If you log in to the device as the root user, you enter the UNIX shell, which is indicated by the percent sign (%) as the prompt. 
 
To access the Junos CLI, enter the cli command at the shell prompt:

![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Juniper/Current/Images/SRX/Junos_cli.png?raw=true)
 
After logging in, you enter operational mode, which is indicated by the right angle bracket (>) From operational mode, use the configure command to enter configuration mode, which is indicated by the pound sign (#):

![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Juniper/Current/Images/SRX/operationalmode.png?raw=true)

One we have logged into Junos CLI we need to see what route can reach the Dynamic Azure Gateway

The Junos command is **run show route**

![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Juniper/Current/Images/SRX/runshowroute.png?raw=true)

In this example fe-0/0/0.0 is the name of the External interface, vlan.1 is the name of the Internal interface
 
We will need to show zone(s) with interface  fe-0/0/0.0
 
The Junos command is **show security zones | display set | match fe-0/0/0.0**

![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Juniper/Current/Images/SRX/internet.png?raw=true)

In this example Zone Internet is associated with interface fe-0/0/0.0
 
We will need to show zone(s) with interface vlan.1
 
The Junos command is **show security zones | display set | match vlan.1**

![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Juniper/Current/Images/SRX/internal.png?raw=true)

In this example Zone Internal is associated with interface vlan.1
 
The following script may need to be modified to suit your device

	###Script Begin###
	set security ike proposal azure-proposal authentication-method pre-shared-keys
	set security ike proposal azure-proposal authentication-algorithm sha1
	set security ike proposal azure-proposal encryption-algorithm aes-256-cbc
	set security ike proposal azure-proposal lifetime-seconds 28800
	set security ike proposal azure-proposal dh-group group2
	set security ike policy azure-policy mode main
	set security ike policy azure-policy proposals azure-proposal
	set security ike policy azure-policy pre-shared-key ascii-text 879ac96b53764ad0b6482e55c0e05a0a
	set security ike gateway azure-gateway ike-policy azure-policy
	set security ike gateway azure-gateway address 40.X.X.X
	set security ike gateway azure-gateway external-interface fe-0/0/0.0
	set security ike gateway azure-gateway version v2-only
	set security ipsec proposal azure-ipsec-proposal protocol esp
	set security ipsec proposal azure-ipsec-proposal authentication-algorithm hmac-sha1-96
	set security ipsec proposal azure-ipsec-proposal encryption-algorithm aes-256-cbc
	set security ipsec proposal azure-ipsec-proposal lifetime-seconds 27000
	set security ipsec policy azure-vpn-policy proposals azure-ipsec-proposal
	set security ipsec vpn azure-ipsec-vpn ike gateway azure-gateway
	set security ipsec vpn azure-ipsec-vpn ike ipsec-policy azure-vpn-policy
	set security zones security-zone Internal interfaces vlan.1
	set security zones security-zone Internal host-inbound-traffic system-services ike
	set security zones security-zone Internal address-book address onprem-networks-1 192.168.1.0/24
	set security zones security-zone Internet interfaces fe-0/0/0.0
	set security zones security-zone Internet host-inbound-traffic system-services ike
	set security zones security-zone Internet address-book address azure-networks-1 10.0.0.0/16
	set security policies from-zone Internal to-zone Internet policy azure-security-Internal-to-Internet-0 match source-address onprem-networks-1
	set security policies from-zone Internal to-zone Internet policy azure-security-Internal-to-Internet-0 match destination-address azure-networks-1
	set security policies from-zone Internal to-zone Internet policy azure-security-Internal-to-Internet-0 match application any
	set security policies from-zone Internal to-zone Internet policy azure-security-Internal-to-Internet-0 then permit
	set security policies from-zone Internet to-zone Internal policy azure-security-Internet-to-Internal-0 match source-address azure-networks-1
	set security policies from-zone Internet to-zone Internal policy azure-security-Internet-to-Internal-0 match destination-address onprem-networks-1
	set security policies from-zone Internet to-zone Internal policy azure-security-Internet-to-Internal-0 match application any
	set security policies from-zone Internet to-zone Internal policy azure-security-Internet-to-Internal-0 then permit
	set interfaces st0 unit 0 family inet
	set security zones security-zone Internet interfaces st0.0
	set security ipsec vpn azure-ipsec-vpn bind-interface st0.0
	set routing-options static route 10.0.0.0/16 next-hop st0.0
	set security flow tcp-mss ipsec-vpn mss 1350
	###Script End###

	##Scriptkey##
	879ac96b53764ad0b6482e55c0e05a0a is the Azure Gateway preshared key
	40.X.X.X is the IP address of the Dynamic Azure gateway
	fe-0/0/0.0 in the external interface
	vlan.1 the name of the internal interface
	Internal is the zone is associated with interface vlan.1
	Internet is the zone is associated with interface fe-0/0/0.0
	192.168.1.0/24 this is IP address range of the onprem-networks
	10.0.0.0/16  this is the IP address rage of the azure-networks

We will need to use the text typed at the terminal as input to the configuration
 
The Junos command is **load set terminal**

![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Juniper/Current/Images/SRX/terminal.png?raw=true)

Copy and paste the edited script into the Juniper console window when completed press **"Control D"** to end input
 
The Junos command is **commit full**

![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Juniper/Current/Images/SRX/commit.png?raw=true)

We need to show the default security policy
 
The Junos command is **show security policies from-zone Internal to-zone Internet** 

![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Juniper/Current/Images/SRX/policys.png?raw=true)

The default policy name in this example is azure-security-Internal-to-Internet-0
 
**If your default policy does not match azure-security-Internal-to-Internet-0 run command:

	insert security policies from-zone Internal to-zone Internet policy azure-security-Internal-tointernet-0 before policy <NameOfYourDefaultTrustToUntrustPolicy>
	commit 

How to check to see main mode is connected
 
The Junos command is **run show security ike security-associations**

![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Juniper/Current/Images/SRX/ike.png?raw=true)

How to check to see Quick Mode is connected  
 
The Junos command is **run show security ipsec security-associations**

![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Juniper/Current/Images/SRX/ipsec.png?raw=true)
 
To exit configuration mode and go back to operational mode, enter **exit** at the prompt:

![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Juniper/Current/Images/SRX/exit.png?raw=true)

Resources:

[SRX show configuration](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Juniper/Current/SRX/juniper-srx-junos_12.1_show_configuration.txt)