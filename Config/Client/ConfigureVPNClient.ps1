param(
    [Parameter(Mandatory=$True)]
    [string]
    $name,

    [Parameter(Mandatory=$True)]
    [string]
    $serverAddress
)

Add-VpnConnection -Name $name -ServerAddress $serverAddress -TunnelType Sstp -RememberCredential -AuthenticationMethod MSChapv2 -EncryptionLevel Required