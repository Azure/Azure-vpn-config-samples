**Supported Platforms**

Microsoft Azure is supported with the following Dell SonicWALL appliances:

- SuperMassive E10000 Series
- SuperMassive 9200 / 9400 / 9600
- E-Class NSA E5500 / E6500 / E7500 / E8500 / E8510
- NSA 2600 / 3600 / 4600 / 5600 / 6600 
- NSA 220 / 220W / 240 / 250M / 250MW / 2400 / 2400MX / 3500 / 4500 / 5000
- TZ 100 / 100W / 105 / 105W / 200 / 200W / 205 / 205W / 210 / 210W / 215 / 215W 
- TZ 300 / 300W / 400 / 400W / 500 / 500W / 600
- SOHO / SOHO W

**Supported firmware**

For the SuperMassive E10000 series, all approved versions of SonicOS support Microsoft Azure.
For platforms other than the SuperMassive E10000 Series, the following SonicOS firmware or hotfixes support the latest version of Microsoft Azure:
![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Dell/Current/Images/firmware.png?raw=true)


Contact Support at [https://support.software.dell.com/manage-service-request](https://support.software.dell.com/manage-service-request) to obtain a hotfix or support build for your Dell SonicWALL firewall. Non-hotfix or support build firmware is available on MySonicWALL for your platform. 

### Creating the Azure VPN Gateway: ###

[![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Cisco/Current/Images/ASAImages/Deploy.jpg?raw=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-site-to-site-vpn%2Fazuredeploy.json)

In example:

Vpn Type: **PolicyBased**

Local virtual network gateway: **208.x.x.40** (Sonicwall external interface IP (Public IP address)

Azure Gateway Public IP Address: **40.x.x.x**

Local Network Address: **192.168.37.0/24** (Your on-premises local network. Specify starting IP address of your network.) 

Azure VNet Address: **40.0.0.0/16**

Shared Key: **s30keBEOikz5Orl1GYI8not22dbnuZCJ**

It takes couple of minutes to create Gateway Connection. Once created review the Virtual Network Gateway IP Address

![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Dell/Current/Images/AzureGW.png?raw=true)

#Sonicwall Configuration#

- Log into the SonicOS management interface as an administrator
- Navigate to the **VPN > Settings** dialog
- Click Add

The VPN Policy dialog displays:

![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Dell/Current/Images/VPNPolicyGen.png?raw=true)

Enter the following information:

- Authentication Method – select **IKE using Preshared Secret**
- Name – Enter a name for the policy (**Azure** is used in this example)
- IPsec Primary Gateway Name or Address in this example **40.x.x.x** For more information, see the [DynRouteVPN](http://documents.software.dell.com/sonicos/6.2/microsoft-azure-configuration-guide/configuring-a-route-based-vpn/azure-configuration-tasks/creating-a-virtual-network-gateway?ParentProduct=646#pid0e0nd0ha) Quick Start dialog.
- Shared Secret – in this example **s30keBEOikz5Orl1GYI8not22dbnuZCJ** For more information, see [Managing Shared Keys](http://documents.software.dell.com/sonicos/6.2/microsoft-azure-configuration-guide/configuring-a-route-based-vpn/azure-configuration-tasks/managing-shared-keys?ParentProduct=646)

Click the Proposals tab:

![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Dell/Current/Images/VPNPolicyPro.png?raw=true)

Click the Exchange drop-down menu, and then select **IKEv2 Mode**.

- Azure supports only IKEv2 Mode for route-based site-to-site VPN. For more information about the settings on this dialog, refer to this MSN article titled [About VPN Devices for Virtual Network](https://azure.microsoft.com/en-us/documentation/articles/vpn-gateway-about-vpn-devices/)

Click the Advanced tab:

![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Dell/Current/Images/VPNPolicyAdv.png?raw=true)

- Enable Keep Alive by checking **Enable Keep Alive** 
- Click the VPN Policy bound to drop-down menu, and then select a WAN interface. For example, **Interface X5** 
- Click **OK**

### Creating an Address Object for the Virtual Network: ###

- Navigate to the **Network > Address Objects** dialog
- Click **Add** to create a new Address Object

The Add Address Object dialog displays:

![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Dell/Current/Images/AddressObj.png?raw=true)
	
	NOTE: The information displayed in this dialog is for example only, and can vary depending on your network.

Enter the following information:

- Name – Enter a name for the **Address Object** (Azure Network is used in this example)
- Zone Assignment – Click the drop-down, and then select **VPN**
- Type – Click the drop-down, and then select **Network**
- Network – in this example **40.0.0.0**
- Netmask/Prefix Length – in this example **255.255.0.0**
- Click **Add**

### Creating a Static Route Policy ###

To create a static route policy, complete the following steps:

- Navigate to the **Network > Routing** dialog
- Click **Add** to create a new Route Policy

The Add Route Policy dialog displays:

![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Dell/Current/Images/Policy.png?raw=true)

Configure Source to the same on-premise network you configured in the Site-to-Site Connectivity dialog.
  
	NOTE: The information displayed in this screenshot is for example only, and could vary depending on your network. 
- Select **Disable route when the interface is disconnected**
- Select **Auto-add Access Rules** 
- Click **OK**

###Testing Connectivity###

To test the connectivity from Azure portal view connection resource
![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Dell/Current/Images/AzureGWConn.png?raw=true)

To test the connectivity from SonicOS:

- Log in to the SonicOS management interface, and navigate to the **VPN > Settings** dialog

In the VPN Policies table, the VPN shows as connected:

![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Dell/Current/Images/VPNSettings.png?raw=true)

	It might take a while for the VPN tunnel to show as connected in the Azure Management Portal.

To test traffic flow from the SonicOS side to the Azure cloud, complete either of the following:

- Try to establish an RDP connection to a Virtual Machine (VM) in the cloud on port 3389 from a host behind the Dell SonicWALL firewall
- Try to ping a VM in the cloud from a host behind the Dell SonicWALL firewall

By default, a VM in the Azure has the inbound ICMP blocked by Windows Firewall and needs to be enabled in Windows using this command:

	netsh advfirewall firewall add rule name="All ICMP V4" protocol=icmpv4:any,any dir=in action=allow
