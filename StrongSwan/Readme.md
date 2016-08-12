# StrongSwan config files

The provided configuration files work with StrongSwan 5.3.5 on Ubuntu and the Route-based (AKA Dynamic) Azure Gateway.

Make sure you modify the files to include your own IP addressing (public, protected networks, etc) and PSK.

There are other things you'll need to do on your StrongSwan box for this setup to work:

In **/etc/strongswan.d/charon.conf**, uncomment and modify this line to leave it as below to avoid routing issues:


	install_routes = no 


**Important:** Without this change, StrongSwan will add routes on a routing table with more priority than the default one. That table doesn't show up in a "ip route list", but you can pull it with "ip route show table 220". If you have skipped this step and are not reading this note, you're now probably hitting your head on a wall as everything looks fine, but your VPN still doesn't work.

Go back to your shell and disable apparmor profiles for Charon and Stroke 

	$ sudo apparmor_parser -R /etc/apparmor.d/usr.lib.ipsec.charon
	$ sudo apparmor_parser -R /etc/apparmor.d/usr.lib.ipsec.stroke
	$ sudo ln -s /etc/apparmor.d/usr.lib.ipsec.charon /etc/apparmor.d/disable/
	$ sudo ln -s /etc/apparmor.d/usr.lib.ipsec.stroke /etc/apparmor.d/disable/

From <https://bugs.launchpad.net/ubuntu/+source/strongswan/+bug/1549436> 

Restart the ipsec daemon:

	$ sudo ipsec restart
	Stopping strongSwan IPsec...
	Starting strongSwan 5.3.5 IPsec [starter]...

Now launch the Azure connection

	$ sudo ipsec up azure
