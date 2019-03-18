# This is a script that will install the EventLogUtil on any server.

#Requires -RunAsAdministrator
param (
    [Alias("i")]
    [Switch]$install,
    [Alias("u")]
    [Switch]$uninstall,
    [String]$logName,
    [String]$sourceName
)
function Main() {
    $logExists = [System.Diagnostics.EventLog]::Exists($logName)
    $sourceExists = [System.Diagnostics.EventLog]::SourceExists($sourceName)
    $exists = $logExists -and $sourceExists
    if ($install) {
        if ($sourceName -eq $null) {
            Write-Host -ForegroundColor Red "A sourceName is required to create the log!"
            exit 1
        }
        if ($exists -eq $false) {
            New-EventLog -LogName $logName -Source $sourceName 
            Write-Output "The log $logName was created, monitoring $sourceName through it."
        }
        else {
            Write-Host -ForegroundColor Red "The Log and Source already exist!"
            exit 1
        }
    }
    if ($uninstall) {
        if ($logExists -eq $true) {
            Remove-EventLog -LogName $logName
            Write-Output "The log $logName was removed." 
        }  
        else {
            Write-Host -ForegroundColor Red "The Log $logName does not exist!"
            exit 1
        }
    }
}
if ($logName -eq $null) {
    Write-Host -ForegroundColor Red "LogName is required!"
    exit 1
}
Main
