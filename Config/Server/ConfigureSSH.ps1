param(
    [string]
    $sshSettingPath,

    [string]
    $installerSourceUrl = "https://bvdl.s3-eu-west-1.amazonaws.com/BvSshServer-Inst.exe",

    [string]
    $installerFileName = "BvSshServer-Inst.exe",

    [string]
    $activationCode = "000000000000000000000000000000000000000000000000000000000000000009CDB0B7E14A00020000FFFFFFFFFFFFFFFFFFFFCEA10000"
)

$installerPath = "$PSScriptRoot\$installerFileName"
if ((Test-Path $installerPath) -eq $false)
{
    Start-BitsTransfer -Source $installerSourceUrl -Destination $installerPath -Description "Downloading Bitvise SSH Server installer"
}

if ($sshSettingPath -eq $null)
{
    Write-Host "Installing Bitvise SSH Server with default settings"
    & $installerPath -defaultInstance -acceptEULA -activationCode="$activationCode" -startService -startBssCtrl
}
else
{
    Write-Host "Installing Bitvise SSH Server with settings file" $sshSettingPath
    & $installerPath -defaultInstance -acceptEULA -settings="$sshSettingPath" -activationCode="$activationCode" -startService -startBssCtrl
}

if (($LastExitCode -band 16) -gt 0)
{
    Write-Host "Restarting computer"
    Restart-Computer
}
