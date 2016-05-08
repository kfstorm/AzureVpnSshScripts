param(
    [Parameter(Mandatory=$True, HelpMessage="The thumbprint of the certificate for remote desktop service")]
    [string]
    $thumbprint
)

Write-Host "Updating the certificate of remote desktop service"
$tsgs = gwmi -class "Win32_TSGeneralSetting" -Namespace root\cimv2\terminalservices -Filter "TerminalName='RDP-tcp'"
swmi -path $tsgs.__path -argument @{SSLCertificateSHA1Hash="$thumbprint"}