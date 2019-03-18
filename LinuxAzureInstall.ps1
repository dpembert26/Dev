# $accountName = ""
# $password = ConvertTo-SecureString "" -AsPlainText -Force
# $credential = New-Object System.Management.Automation.PSCredential($accountName, $password)
# Install-Module -Name AzureRM -Force 
# Import-Module AzureRM
Login-AzureRmAccount 

$vm_array = @("xxxxxxxxxxxxxxxx","xxxxxxxxxxxxxxx","xxxxxxxxxxxxxx","xxxxxxxxxxx","xxxxxxxxxxxx","xxxxxxxxxxxx","xxxxsxxxx")
foreach($vm in $vm_array){
Set-AzureRmVMExtension -SettingString '{"xxxxxxxxxxxLicenseKey":"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}' `
-Publisher xxxxxxxxxxxx -ExtensionType xxxxxxxxxxLinuxServerExtn -Version 1.3 -Name "xxxxxxxxxxLinuxServerAgent" -ResourceGroupName "xxxxxxxxxxxxxxxxxxxxxx" -Location "Sxxxxxxxx Cxxxxxx US" -VMName "$vm"
 }

