$wmi_status = Get-Service winmgmt 
if($wmi_status.status -ne "Running"){
  start-service winmgmt
  }
 $wmi_mode = Get-Service winmgmt | Select-Object -Property name, starttype
 if($wmi_mode.StartType -ne "Automatic"){
   Set-Service -Name winmgmt -ComputerName . -StartupType Automatic
   }
 
