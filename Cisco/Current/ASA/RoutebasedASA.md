! Microsoft Corporation
! Windows Azure Virtual Network

! This configuration template applies to Cisco ASA devices running version 9.8.1 software and later.
! It configures an IPSec VPN tunnel connecting your on-premise VPN device with the Azure gateway.
! Names that begin with "azure-" are variable names and can be changed consistently.

! ---------------------------------------------------------------------------------------------------------------------
! Enable IKEv2 on Outside interface
!
! The following enables IKEv2 on the external interface of the ASA.  Adjust to match the nameif of the internet facing
! interface.  Additionally adjust the source interface name on the tunnel definition.

crypto ikev2 enable outside

! ---------------------------------------------------------------------------------------------------------------------
! Set MSS and Preserve VPN Flows
!
! To avoid fragmentation and to preserve flows if the VPN tunnel drops (eg to avoid having to recreate a TCP session),
! include the following commands.

sysopt connection tcpmss 1350
sysopt connection preserve-vpn-flows

! ---------------------------------------------------------------------------------------------------------------------
! Internet Key Exchange (IKEv2) configuration
! 
! This section specifies the authentication, encryption, hashing, and Diffie-Hellman group parameters for the Phase
! 1 negotiation and the main mode security association.
! 
! In this example 10.0.0.0/8 is the on premises network & 192.168.1.0/16 is the Azure Virtual Network
! In this example the Azure Gateway IP Address is 40.76.X.X and your Outside Interface IP Address is 131.X.X.X

crypto ikev2 policy 3
  encryption aes-256
  integrity sha
  group 2
  prf sha
  lifetime seconds 10800

crypto ipsec ikev2 ipsec-proposal azure-proposal
  protocol esp encryption aes-256
  protocol esp integrity sha-1

! ---------------------------------------------------------------------------------------------------------------------
! Crypto and Tunnel configuration
!
! This section defines a crypto profile that binds the cross-premise network traffic to the IPSec transform set and
! remote peer. We also bind the IPSec policy to the virtual tunnel interface, through which cross-premise traffic will
! be transmitted.
!
! We have picked an arbitrary tunnel id "1" as an example. If that happens to conflict with an existing virtual tunnel
! interface, you may choose to use a different id.
!
! The IP address 169.254.0.1 acts as the "inner" address of the tunnel. Essentially it has one job, to deliver traffic
! from the Azure side to the on-prem side. As it does not need to reach the Internet, it being routable is not
! necessary. The ASA has an internal routing table and knows what to do with the traffic. You should be able to use
! any 169.254.X.X address.
!
! The tunnel group configuration sets the type of VPN to be created (Site-to-Site) as well as the pre-shared key to
! be used for authentication.
!
! Finally, a route is created to forward traffic for Azure networks through the tunnel interface. 

crypto ipsec profile azure-profile
  set ikev2 ipsec-proposal azure-proposal
  set pfs group2
  set security-association lifetime kilobytes 102400000
  set security-association lifetime seconds 10800

interface Tunnel1
  nameif azure-vpn
  ip address 169.254.0.1 255.255.255.0
  tunnel source interface outside
  tunnel destination 40.76.X.X
  tunnel mode ipsec ipv4
  tunnel protection ipsec profile azure-profile

tunnel-group 40.76.X.X type ipsec-l2l
tunnel-group 40.76.X.X ipsec-attributes
  ikev2 remote-authentication pre-shared-key XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  ikev2 local-authentication pre-shared-key XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

route azure-vpn 192.168.1.0 255.255.0.0 40.76.X.X 1
