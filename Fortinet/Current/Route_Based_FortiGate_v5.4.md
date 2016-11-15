**Configure Azure via JSON template:**
=============

[![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Fortinet/Images/Deploy.jpg?raw=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-site-to-site-vpn%2Fazuredeploy.json)

[https://github.com/Azure/azure-quickstart-templates/tree/master/201-site-to-site-vpn](https://github.com/Azure/azure-quickstart-templates/tree/master/201-site-to-site-vpn)

![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Fortinet/Images/S2S_JASON.jpg?raw=true)

After Site 2 Site connection is deployed review your Azure gateway address and your Local gateway IP address:
![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Fortinet/Images/Azure_GW.jpg?raw=true)

**Configure the Fortigate**
=============
Login into the forgate management under **VPN => IPsecWizard** Select Custom:
![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Fortinet/Images/Fortigate_custom.jpg?raw=true)

Configure the VPN tunnel as outlined below:
![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Fortinet/Images/NewVPNTunnel.jpg?raw=true)

Under **Network => Static Routes** Create a new static route to the Azure vnet address space:
![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Fortinet/Images/FortigateRoute.jpg?raw=true)

Under **Policy & Objects => Addresses** add the Azure vnet address space:
![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Fortinet/Images/Fortigate_azure_address.jpg?raw=true)

Add the Local Address space for the FortiGate:
![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Fortinet/Images/Fortigate_local_address.jpg?raw=true)

Under **Policy & Objects => IPV4 Policy** Allow the firewall to accept incoming traffic from the Azure vnet:
![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Fortinet/Images/incomingpolicy.jpg?raw=true)

Create a 2nd firewall policy to allow outgoing traffic from the FortiGate to the Azure vnet:
![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Fortinet/Images/outgoingpolicy.jpg?raw=true)

View the policy number for outgoing by hovering your mouse over the sequence number. In this case the Policy ID is **2**:
![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Fortinet/Images/sequuencenumber.jpg?raw=true)

In **Dashboard = > CLI Console** 
Enter the following commands:

- **config firewall policy** 
- **edit 2** *(where 2 is the policy id listed above)*
- **set tcp-mss-sender 1350**
- **set tcp-mss-receiver  1350**
- **next** 
- **end**

![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Fortinet/Images/Cli_console.jpg?raw=true)

Insure your setting are correct by running **show firewall policy 2** *(where 2 is the policy id listed above)*
![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Fortinet/Images/showfirewallpolicy.jpg?raw=true)

Under **Monitor => IPSec Monitor** right click to bring up the gateway
![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Fortinet/Images/IPSecMontor.jpg?raw=true)

Ensure the VPN tunnel comes up on the FortiGate:
![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Fortinet/Images/VPNUP.jpg?raw=true)

The Azure portal will update within a few moments:

![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Fortinet/Images/AzureUP.jpg?raw=true)

 







 


