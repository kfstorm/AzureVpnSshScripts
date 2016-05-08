# Tested under Windows Server 2012 R2
# "Run as administrater" is required

param(
    [Parameter(Mandatory=$True, HelpMessage="The thumbprint of the certificate for remote desktop server identity")]
    [string]
    $thumbprint,

    [Parameter(Mandatory=$True, HelpMessage="The pre-shared key when using L2TP/IPSec")]
    [string]
    $preSharedKey,

    [string[]]
    $ipAddressRange = ("10.99.0.1", "10.99.0.128"),

    [string[]]
    $users = ($env:USERNAME)
)

$externalInterface= (Get-NetAdapter -Physical)[0].Name

#Write-Host "Uninstalling feature: Routing"
#Uninstall-WindowsFeature Routing
Write-Host "Installing feature: Routing"
Install-WindowsFeature Routing -IncludeManagementTools
Write-Host "Uninstalling Remote Access"
Uninstall-RemoteAccess -Force
Write-Host "Installing Remote Access"
Install-RemoteAccess -VpnType VpnS2S -IPAddressRange $ipAddressRange

netsh ras set type ipv4rtrtype = lananddd ipv6rtrtype = none rastype = ipv4
netsh ras set wanports device = "WAN Miniport (SSTP)" rasinonly = enabled ddinout = disabled ddoutonly = disabled maxports = 128
netsh ras set wanports device = "WAN Miniport (IKEv2)" rasinonly = enabled ddinout = enabled ddoutonly = disabled maxports = 128
netsh ras set wanports device = "WAN Miniport (PPTP)" rasinonly = enabled ddinout = enabled ddoutonly = disabled maxports = 128
netsh ras set wanports device = "WAN Miniport (L2TP)" rasinonly = enabled ddinout = enabled ddoutonly = disabled maxports = 128
$users | foreach { netsh ras set user name = "$_" dialin = permit cbpolicy = none }
netsh ras aaaa set authentication provider = windows
netsh ras aaaa set accounting provider = windows
netsh ras aaaa set ipsecpolicy psk=enabled secret="$preSharedKey"

netsh ras set sstp-ssl-cert hash="$thumbprint"

netsh ras ip set addrassign method = pool

#cmd.exe /c "netsh routing ip nat uninstall"
netsh routing reset
netsh routing ip nat install
netsh routing ip nat add interface "$externalInterface"
netsh routing ip nat set interface "$externalInterface" mode=full

netsh routing ip igmp install
netsh routing ip relay install
netsh routing ip relay add interface name="Internal"
netsh routing ip relay set interface name="Internal" relaymode=enable maxhop=4 minsecs=4

$rule = Get-NetFirewallRule -DisplayName IKEv2 -ErrorAction SilentlyContinue
if ($rule -eq $null)
{
    New-NetFirewallRule -DisplayName IKEv2 -Direction Inbound -LocalPort 4500 -Protocol UDP
}

net stop RemoteAccess
net start RemoteAccess
