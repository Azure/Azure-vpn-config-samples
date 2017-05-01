##Configure Azure via JSON template:##

[![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Fortinet/Images/Deploy.jpg?raw=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-site-to-site-vpn%2Fazuredeploy.json)

[https://github.com/Azure/azure-quickstart-templates/tree/master/201-site-to-site-vpn](https://github.com/Azure/azure-quickstart-templates/tree/master/201-site-to-site-vpn)

In example:

Vpn Type: **RouteBased**

Local virtual network gateway Ip Address: **8.X.X.X** (WAN interface IP or Public IP address) 

Azure Gateway Public IP Address: **40.x.x.x**

Local Network Prefix: **192.168.1.0/24** (Your on-premises local network. Specify starting IP address of your network.) 

Azure VNet Address: **10.0.0.0/16**

Shared Key: **eFMx0xib2hc5F7FagVOeOcWIfr9Rj9**

After Site 2 Site connection is deployed review your Azure gateway address and your Local gateway IP address:
![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Fortinet/Images/Azure_GW.jpg?raw=true)

##Configure the paloaltonetworks VPN##

**Required Software Version 8.0.0**

Tunnel Interface
Inside the WebGUI in **Network** > **Interfaces** > **Tunnel**, Add a new tunnel interface

![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/PaloAlto/Images/Tunnel.jpg?raw=true)

IKE Gateway
Add an IKE Gateway **Network** > **IKE Gateway** 

![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/PaloAlto/Images/IKE_GATEWAY.jpg?raw=true)

Create a new IKE Crypto Profile

![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/PaloAlto/Images/new_IKE_Cypto.jpg?raw=true)

Example Profile:

![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/PaloAlto/Images/IKE_Crypto_Profile.jpg?raw=true)

Enable **Liveness Check**

![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/PaloAlto/Images/IKE_GATEWAY_ADV.jpg?raw=true)

Add a new IPSec tunnel **Network** > **IPSec Tunnels**

- Choose the Tunnel Interface created in at the beginning of this document 
- Create a new IPSec Crypto Profile

![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/PaloAlto/Images/New_IPSEC_Profile.jpg?raw=true)

![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/PaloAlto/Images/IPSec_Crypto_Profile.jpg?raw=true)

Completed IPSec Tunnel

![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/PaloAlto/Images/IPSEC_Tunnel.jpg?raw=true)

Change Virtual Router settings **Network** > **Virtual Router** > *VR_Name*

- Create a Static Route to Azure Vnet

![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/PaloAlto/Images/Virtual_Router.jpg?raw=true)

Under **Network** > **IPSec Tunnels** the Azure tunnel should update within a few moments 

![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/PaloAlto/Images/Tunnel_UP.jpg?raw=true)

The Azure portal will also update within a few moments:

![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Fortinet/Images/AzureUP.jpg?raw=true)

Resources:


 







 


