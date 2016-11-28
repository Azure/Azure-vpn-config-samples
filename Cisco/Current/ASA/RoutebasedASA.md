### Explaining the limitation with Cisco ASA and RouteBased Azure Gateways ###

ASA currently doesn't support [VTI](http://www.cisco.com/en/US/technologies/tk583/tk372/technologies_white_paper0900aecd8029d629_ps6635_Products_White_Paper.html), so RouteBased connections to the Azure gateway are not possible.

Documentation from [Microsoft:](https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpn-devices)

[![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Cisco/Current/Images/ASAImages/Microsoft_documation.png?raw=true)
](https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpn-devices)
Documentation from [Cisco:](https://supportforums.cisco.com/blog/12926156/site-site-vpn-between-cisco-asa-and-microsoft-azure-virtual-network-arm) 

[![](https://github.com/Azure/Azure-vpn-config-samples/blob/master/Cisco/Current/Images/ASAImages/ASAlimit.png?raw=true)](https://supportforums.cisco.com/blog/12926156/site-site-vpn-between-cisco-asa-and-microsoft-azure-virtual-network-arm)
