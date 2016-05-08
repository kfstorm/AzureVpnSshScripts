# Azure VPN/SSH scripts

This project contains scripts to enable VPN and/or SSH on Azure VM with command line. You don't need to re-configure VPN or SSH again and again when you want to recreate a VM or the network adapter changed.

## What it can do
  - Create a new Azure VM with nessesary NSG rules with command line
  - Set up VPN on Windows Server
  - Set up SSH server
  - Configure remote desktop certificate

## Usage

* Deploy a new VM with nessesary NSG rules
    1. Update parameters in `AzureVMDeployment\parameters.json` for your to be created VM. This file includes parameters such as VM name, location, username and password, storage account name.
    2. Run below Powershell script. (Insure you have installed `Microsoft Azure Powershell`.)
        
        ```powershell
        pushd .\AzureVMDeployment\
        .\deploy.ps1 -subscriptionId "your_subscription_id_here" -resourceGroupName "your_resource_group_name_here" -resourceGroupLocation "your_resource_group_location_here" -deploymentName "your_deployment_name_here"
        popd
        ```
* Configure VPN server
    1. Use remote desktop to log on to the VM you want to enable VPN.
    2. Copy files in `Config\Server` to any folder of the VM.
    3. Copy the certificate (.pfx) you want to use to the VM.
    4. In the VM, run below Powershell script at the folder where you copied files of step 2. You'll be prompted to type the password of the pfx file.
        
        ```powershell
        $cert = .\InstallCert.ps1 -pfxPath "your_certificate_file_path"
        .\ConfigureVPN.ps1 -thumbprint $cert.Thumbprint -preSharedKey "your_presharedkey_for_l2tp_ipsec_here"
        ```
* Configure SSH server
    1. Use remote desktop to log on to the VM you want to enable VPN.
    2. Copy files in `Config\Server` to any folder of the VM.
    3. Optionally, copy your exported Bitvise SSH server settings file to any folder the VM.
    4. In the VM, run below Powershell script at the folder where you copied files of step 2.
        
        ```powershell
         .\ConfigureSSH.ps1 -sshSettingPath "your_bitvise_ssh_server_settings_file.wst"
        ```
        If you don't have a previously exported Bitvise SSH server settings file, just run above command without `-sshSettingsPath` parameter.
    5. If it's your first time to configure SSH, the VM will restart automatically. Just wait.
* Configure remote desktop certificate
    1. Use remote desktop to log on to the VM you want to enable VPN.
    2. Copy files in `Config\Server` to any folder of the VM.
    3. Copy the certificate (.pfx) you want to use to the VM.
    4. In the VM, run below Powershell script at the folder where you copied files of step 2. You'll be prompted to type the password of the pfx file.
        
        ```powershell
        $cert = .\InstallCert.ps1 -pfxPath "your_certificate_file_path"
        .\ConfigureRDP.ps1 -thumbprint $cert.Thumbprint
        ```
* Configure VPN client
    1. On your client machine, run below Powershell script.
        
        ```powershell
        .\Config\Client\ConfigureVPNClient.ps1 -name "your_vpn_connection_name_here" -serverAddress "your_vpn_server_address_here"
        ```
* Configure SSH client
    1. Download and install Bitvise SSH Client from [here](https://www.bitvise.com/ssh-client-download). (Or you can use any other SSH client you want.)
    2. Run Bitvise SSH Client and input your server address and port and enjoy.
    3. Optionally, you can create a scheduled task with below command to start Bitvise SSH Client with profile when log on to computer.
        
        ```batch
        "C:\Program Files (x86)\Bitvise SSH Client\BvSsh.exe" -profile="your_bitvise_ssh_client_profile.bscp" -loginOnStartup
        ```
