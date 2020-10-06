# <span style="color:#0080FF">Creating a Site-to-Site VPN from a Barracuda firewall to Azure </span>
The goal is to create a VPN between a local network and Azure, to secure the communication between the two environments. The Azure IP address space can be a public address space, where the various services are accessed using a public URL, or it can be a private address space (e.g 10.x.x.x), to further increase security. This document does not go into details of creating a Vnet in Azure or setting up DNS forwarders to resolve private URLs, it deals only with setting up the VPN with a Barracuda firewall.

## <span style="color:#0080FF">Tested firewall </span>
The configuration example in the sections below has been tested on the following device:

- Model: Barracuda F18
- Firmware version: 7.2.3-161
- Licensed software: ClougGen Firewall OS

## <span style="color:#0080FF">High level architecture </span>
<img src="images/architecture.jpg" width="600"/><p>

**VPN architecture**<p>



## <span style="color:#0080FF">In the Azure portal </span>

You need to create objects representing the Barracuda gateway, the Azure gateway, and the connection between them. The easiest way to do this is with the Azure template to create a Site-to-Site VPN:<p>
        [<img src="images/Create_a_Site-to-Site_VPN_Connection.JPG" width="600"/>](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-site-to-site-vpn%2Fazuredeploy.json)<p>


In the wizard enter the following:


- Vpn Type: **Route-based**
- Local virtual network gateway: **24.x.x.x** (Barracuda external interface IP (Public IP address)
- Azure Gateway Public IP Address: **40.x.x.x**
- Local Network Address: **192.168.0.0/16** (On-premises local network. Specify starting IP address of your network.) 
- Azure VNet Address: **40.0.0.0/16**
- Shared Key: **s30keBEOikz5Orl1GYI8not22dbnuZCJ**

After the deployment is finished, review the three items created. Screens:<p>
    <img src="images/Azure_gateway.JPG" width="600"/><p>
    **The Azure gateway**<p>
    <img src="images/Local_gateway.JPG" width="600"/><p>
    **The local gateway**<p>
    <img src="images/Connection.JPG" width="600"/><p>
    **The connection between them**<p>

Once the Azure deployment is done, you can configure the Barracuda firewall.

## <span style="color:#0080FF">In the Barracuda firewall administration tool</span>

Barracuda guidance can be found [here](https://campus.barracuda.com/product/cloudgenfirewall/doc/73719171/how-to-configure-an-ikev2-ipsec-site-to-site-vpn-to-a-routed-based-microsoft-azure-vpn-gateway/)

Start by logging in to the Barracuda firewall as administrator

<img src="images/Barracuda_login.JPG" width="300"/>

**Barracuda CloudGen Firewall login screen**

Next, configure the following items:

### <span style="color:#0080FF">IPSec Tunnel</span>

- Open Configuration Tree &#10132; Box &#10132; Virtual Servers &#10132; <span style="color:#0080FF">\<virtual server \></span> &#10132; Assigned Services &#10132; VPN-Service &#10132; 
- Double-click on Site to Site<p> 
    <img src="images/Site_to_Site.JPG" width="300"/><p>
- Select IPSec IKEv2 Tunnels tab
- Right click in white space, select "New IPSec IKEv2 Tunnel"
- Sample entries
    - Local gateway: 0.0.0.0 
    - Network address: 192.168.0.0/16 (IP range in local network)
    - Remote gateway: 40.x.x.x (Azure Gateway public IP address) 
    - Network address: 10.2.0.0/16 (IP range in Azure that this gateway serves, here shown as a private VNET address, but does not have to be)
    - Shared secret: xxxxxxxxx (from Azure VPN Gateway configuration above)
    - Enabled: yes
- Screens<p>
        <img src="images/IPSec_IKEv2_Tunnel_pt_1.JPG" width="300"/><p>
        **New IPSec IKEv2 Tunnel entry screen, top**<p><p>
        <img src="images/IPSec_IKEv2_Tunnel_pt_2.JPG" width="300"/><p>
        **New IPSec IKEv2 Tunnel entry screen, bottom**

### <span style="color:#0080FF">Forwarding Rule for traffic from local network to Azure</span>

- Open Configuration Tree &#10132; Box &#10132; Virtual Servers &#10132; <span style="color:#0080FF">\<virtual server \></span> &#10132; Assigned Services &#10132; NGFW (Firewall) &#10132; Forwarding Rules 
- Create new forwarding rule
- Example entries
    - Source: Trusted LAN
    - Service: Any
    - Destination: 10.2.0.0/16 (IP range in Azure that the gateway serves, here shown as a private VNET address, but does not have to be)
- Activated: yes
- Screen:<p>
    <img src="images/Outbound_rule.JPG" width="300"/><p>
    **New outbound Forwarding Rule entry screen**<p>

### <span style="color:#0080FF">Forwarding Rule for traffic from Azure to local network </span>
- Open Configuration Tree &#10132; Box &#10132; Virtual Servers &#10132; <span style="color:#0080FF">\<virtual server \></span> &#10132; Assigned Services &#10132; NGFW (Firewall) &#10132; Forwarding Rules 
- Create new forwarding rule
- Example entries
    - Source: Internet
    - Service: IPSEC-VPN
    - Destination: <explicit-dest> 24.x.x.x (Public IP of Barracuda)
- Activated: yes
- Screen:<p>
    <img src="images/Inbound_rule.JPG" width="300"/><p>
    **New inbound Forwarding Rule entry screen**<p>

### <span style="color:#0080FF">Service properties</span>

- Open Configuration Tree &#10132; Box &#10132; Virtual Servers &#10132;  <span style="color:#0080FF">\<virtual server \></span> &#10132; Assigned Services &#10132; VPN (VPN-Service ) &#10132;  Service Properties
- Enable VPN service
- Screen:<p>
    <img  src="images/Service_properties.JPG" width="300" border="5" /><p>
    **Service properties entry screen**<p>
