# This is a PowerShell script to do a docker cleanup and temp file delete on the Windows docker server called xxxx-xx-xxxx (xx.xx.xx.xx)

# Check docker service and stop
Write-Output "Checking status of the Docker service"
$result = Get-Service -Name "Docker"
if($result.status -eq "Running"){
    Write-Output "Docker service is running"
    Stop-Service -Name "Docker"
    Write-Output "Docker service is now stopped"
}
Else{
    "Do nothing, service already stopped"
}

# Make sure service is not set to startup automatically
Write-Output "Checking if the Docker service is starting up automatically"
$auto_mode = Get-Service Docker | select-Object  -Property Name, StartType
if ($auto_mode.StartType -eq "Automatic") {
    Write-Output "The Docker service is set to start automatically"
     Set-Service -Name winmgmt -ComputerName . -StartupType Disabled
     Write-Output "The Docker service is now set as disabled"

}
Else{
    "Do nothing, service already disabled"
}

# Function to Run the docker cleanup command
Function DockerCleanup(){
Set-Location "C:\Users\backupadmin\Downloads"
$comm_result = Invoke-Expression   -Command ".\docker-ci-zap.exe -folder C:\ProgramData\docker"
if($comm_result -like "ERROR:"){
    $date = Get-Date
    $file = Test-Path "C:\DockerCleanup_$date.log"
    Invoke-Expression -Command "del /q /s C:\Windows\Temp\*.*"
    if ($file) {
        Write-Output "Logfile exists"
        Add-Content -Path $file -Value $comm_result
    }
    else {
        $file = new-item -Path "C:\" -Name "DockerCleanup_$date.log"
        Add-Content -Path $file -Value "Docker Cleanup Script"
        Add-Content -Path $file -Value $comm_result
    }
}
    # Setup and send email with attachment of error
    $From = "Alert Scheduled Task <xxxxxx@xxxxxxx.com>"
    $To = "xxxxxx Team <xxxxxxx@xxxxxxx.com>"
    $Subject = "Scheduled task 'Docker Cleanup' failed!"
    $Body = "The scheduled task failed with Error: $comm_result .The server may need to be scheduled for a restart before the command could run successfully. "
    $SMTPServer = "xxxxxxxx.xxxxxxx.com"
    $SMTPPort = "25"

    Send-MailMessage -From $From -to $To -Subject $Subject `
        -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -Attachments $file # -UseSsl `

    Write-Output "The Docker service will now be set to start automatically"
    Set-Service -Name Docker -ComputerName . -StartupType Automatic
    Write-Output "The Docker service will not be set to start automatically" 
    Start-Service -Name "Docker"    
}
Else{
    Invoke-Expression -Command "del /q /s C:\Windows\Temp\*.*"

    Write-Output "The Docker service will now be set to start automatically"
    Set-Service -Name Docker -ComputerName . -StartupType Automatic
    Write-Output "The Docker service will not be set to start automatically" 
    Start-Service -Name "Docker"
}
