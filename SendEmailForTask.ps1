try{
$ScheduledTaskName = "TrackerAutoUpdate"    
$Result = (schtasks /query /FO LIST /V /TN $ScheduledTaskName  | findstr "Result")
$date = Get-Date -f yyyy-MM-dd
$file_conf = Test-Path "C:\Azurexxxxxxxx_$date.log"
if($file_conf){
    Write-Output "Logfile exists"
    $file = "C:\Azurexxxxxxxx_$date.log"
    Add-Content -Path $file -Value $Result
}
else {
$file = new-item -Path "C:\" -Name "Azurexxxxxxxxxxx_$date.log" -ItemType "file"
Add-Content -Path $file -Value "Azure xxxxxxxx script logs"
Add-Content -Path $file -Value $Result
}
$Result = $Result.substring(12)
$Code = $Result.trim()

If ($Code -gt 0) {
    # $User = "xxxxxxxxx@xxxxxxxxxxxx.com"
    # $Pass = ConvertTo-SecureString -String "myPassword" -AsPlainText -Force
    # $Cred = New-Object System.Management.Automation.PSCredential $User, $Pass
################################################################################

$From = "Alert Scheduled Task <xxxxxxxx@xxxxxxxxxxx.com>"
$To = "xxxxxxxx Team <xxxxxxxxxx@xxxxxxxxxxxx.com>"
$Subject = "Scheduled task 'Backup' failed!"
$Body = "The scheduled task failed with Error code: $Code"
$SMTPServer = "xxxxxxxx.xxxxxxxxxx.com"
$SMTPPort = "25"

Send-MailMessage -From $From -to $To -Subject $Subject `
-Body $Body -SmtpServer $SMTPServer -port $SMTPPort -Attachments $file # -UseSsl `
# -Credential $Cred 
}
Else{
    $From = "Alert Scheduled Task <xxxxxxxxx@xxxxxxxxx.com>"
    $To = @("xxxxxxx Team <xxxxxxx@xxxxxxx.com>", "xxxxxxxx Team <xxxxxxxxx@xxxxxxxx.com>")
    $Subject = "Scheduled task 'xxxxxxxxx' was successful!"
    $Body = "The scheduled task was successful"
    $SMTPServer = "xxxxxx.xxxxxxxxx.com"
    $SMTPPort = "25"

    Send-MailMessage -From $From -to $To -Subject $Subject `
    -Body $Body -SmtpServer $SMTPServer -port $SMTPPort
}
 }

 catch{
     "An error occurred that could not be resolved."
 }
