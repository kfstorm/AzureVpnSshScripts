param(
    [Parameter(Mandatory=$True, HelpMessage="The path of the PFX file contains the certificate")]
    [string]
    $pfxPath,

    [Parameter(Mandatory=$True, HelpMessage="The password of the PFX file")]
    [SecureString]
    $pfxPassword
)
Write-Host "Importing certificate from" $pfxPath
$certificate = Import-PfxCertificate -FilePath $pfxPath -CertStoreLocation "Cert:\LocalMachine\My" -Password $pfxPassword -ErrorAction Stop
$subjectName = $certificate.Subject -replace "CN=", ""
Write-Host "Granting access to certificate private key"
& $PSScriptRoot\winhttpcertcfg.exe -g -c LOCAL_MACHINE\MY -s $subjectName -a "\Network Service"
return $certificate
