Function update_repo($name,$ver) {
    ##########################################################################
    #  Get the contents of the PowershellVerList.txt file from GitHub
    ##########################################################################

    # Enable TLS protocols
    $AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
    [System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols

    # Define Repo and file new message
    $owner = "xxxxxx-xxxx"
    $repo = "xxxxxx-xxxxx"
    $path = "xxxxxxxx/xxxxxxxxxx.txt"
    $date = Get-Date
    $new_message = "These servers have a PowerShell version more than 3.0 but not the very latest:"
    $message = "$name"

    # Token and URL
    $token = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    $url = "https://api.github.com/repos/$owner/$repo/contents/$path"

    # Convert token to base64 for use in the RestMethod
    $base64Token = [System.Convert]::ToBase64String([char[]]$token)
    $headers = @{
        Authorization = 'Basic {0}' -f $base64Token
        # Accept = 'application/vnd.github.v4.raw
    };


    # Get Method
    try {
        $result = Invoke-RestMethod  -Method GET  -Headers $headers -Uri $url -ContentType 'Application/json'
    }
    catch {
        "The file xxxxxxxxxxxxxxxxxxxxxxx.txt does not exist in the repository. A new file will be created"
    }


    # If result variable has a value, then get the new sha and existing file content
    if ($result) {
        $old_content = $result.content
        $newsha = $result.sha
        $size = $result.size
        
        $contents = [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($result.content))
        write-output $contents 
        $serv = $contents -replace '(?s).+latest:(.+)' , '$1'
        write-output $serv + "    " + $name
        if($serv -match $name){
            $flag = 'yes'
        }  
        else{
            $flag = 'no'    
          }
        
        write-output "The flag is set to $flag"

        # Body for deleting the file from the Repo
        $delete_body = @{
            "message" = "File deleted on $date"
            "Name"    = "PowerShell EnableWinRM Script"
            "sha"     = "$newsha"
        }

        # Concatenating the original message to the new message and converting to base64
        $fresh_content = $new_message + "`n" + $message + " has PowerShell version " + $ver +  "`n"
        $Bytes = [System.Text.Encoding]::UTF8.GetBytes($fresh_content)
        $new_contents = [System.Convert]::ToBase64String($Bytes)


        # Body for creating the new file in the Repo
        $new_body = @{
            "message"   = "File created on $date"
            "Committer" = @{
                "Name" = "PowerShell EnableWinRM Script"
            }
            "content"   = "$new_contents"
            "sha"       = "$newsha"
        }

        # Convert Bodies to JSON for the RestMethod calls
        $delete_body = $delete_body | ConvertTo-Json
        $new_body = $new_body | ConvertTo-Json


        # If the file size in the Repo is greater than 100KB, then the file will be deleted and a new one created
        if ($size -gt 900 -and $flag -eq 'no') {

            # Convert content to string
            $str_content = [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($old_content))
            Write-Output "This is the string that will be written to the new file: $str_content"


            # Send Email with results from xxxxxxxxxxxxxxxxxxxx.txt
            $From = "Alert: These servers have a PowerShell version more than 3.0 but not the very latest: <devops@corcoran.com>"
            $To = "xxxxxxxxxx Team <xxxxxxxxxx@xxxxxxxxx.com>"
            $Subject = "These servers have a PowerShell version more than 3.0 but not the very latest:"
            $email_Body = "$str_content"
            $SMTPServer = "xxxxxxxxxx.xxxxxxxx.com"
            $SMTPPort = "25"
            # $anonUsername = "anonymous"
            # $anonPassword = ConvertTo-SecureString -String "anonymous" -AsPlainText -Force
            # $creds = New-Object System.Management.Automation.PSCredential($anonUsername,$anonPassword)

            # Command to send email message with content from the file in the Repo
            Send-MailMessage -From $From -to $To -Subject $Subject `
                -Body $email_Body -SmtpServer $SMTPServer -Port $SMTPPort  # -UseSsl `




            # Delete PowershellVerList.txt from repository
            Invoke-RestMethod  -Method DELETE  -Headers $headers  -Body $delete_body -Uri $url -ContentType 'Application/json'
            Write-Output "The file, PowershellVerList.txt was deleted"
            # Create new PowershellVerList.txt in repository
            Write-Output "Create new file called PowershellVerList.txt"
            Invoke-RestMethod  -Method PUT  -Headers $headers  -Body $new_body -Uri $url -ContentType 'Application/json'

        }
        Elseif($size -lt 900 -and $flag -eq 'no') {

            ################################################################################################
            # Update the contents of the PowershellVerList.txt file on GitHub
            ################################################################################################

            # Enable TLS protocols
            $AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
            [System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols

            # Define Repo, new file name and server name
            $owner = "xxxxxxxxxxx-xxxxxx"
            $repo = "xxxxxxxxx-xxxxxxxxxxxx"
            $path = "xxxxxxxxxxxx/xxxxxxxxxxxxxx.txt"
            $message = $name
            $date = Get-Date

            # Decode old file contents from base64 to string
            $old_string = [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($old_content))


            # Concatenate the string with old contents and the server name. Then convert to base64
            $final_content = $old_string + "" + $message +  " has PowerShell version " + $ver + "`n"
            $Bytes = [System.Text.Encoding]::UTF8.GetBytes($final_content)
            $main_contents = [System.Convert]::ToBase64String($Bytes)

           # Body for updating file in the Repo
            $body = @{
                "message"   = "File updated on $date"
                "Committer" = @{
                    "Name" = "PowerShell EnableWinRM Script"
                }
                "content"   = "$main_contents"
                "sha"       = "$newsha"
            }

            # Cocnvert Body to JSON for RestMethod.
            $body = $body | ConvertTo-Json
            $body
            $token = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
            $url = "https://api.github.com/repos/$owner/$repo/contents/$path"

            # Convert token to base64 for use in the RestMethod
            $base64Token = [System.Convert]::ToBase64String([char[]]$token)
            $headers = @{
                Authorization = 'Basic {0}' -f $base64Token
                # Accept = 'application/vnd.github.v4.raw
            };

            # Update the xxxxxxxxxxxxxxxxxx.txt file in the Repo
            $result = Invoke-RestMethod  -Method PUT  -Headers $headers  -Body $body -Uri $url -ContentType 'Application/json'
            $result
    }
    Else{
        # Do nothing
        write-output "This server was aleady noted in the Repo. No need to repeat."
        }
      }
    Else {

        # Create new file xxxxxxxxxxxxxxxxx.txt if old one does not exist in the Repo
        # Enable TLS protocols
        $AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
        [System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols

        # Define Repo, file name and server name
        $owner = "xxxxxxxxxxxxx-xxxxxxx"
        $repo = "xxxxxxxxxx-xxxxxxxx"
        $path = "xxxxxxxxxxx/xxxxxxxxxxxxxxxxx.txt"
        $message = $name
        $date = Get-Date

        # Define old string to put at the begining of the file in the Repo
        $old_string = "These servers have a PowerShell version more than 3.0 but not the very latest:"

        # Concatenate the old text string with the server name and convert to base64
        $final_content = $old_string + "`n" + $message  + " has PowerShell version " + $ver + "`n"
        $Bytes = [System.Text.Encoding]::UTF8.GetBytes($final_content)
        $main_contents = [System.Convert]::ToBase64String($Bytes)

        # Body for creating new file in the Repo
        $create_body = @{
            "message"   = "File updated on $date"
            "Committer" = @{
                "Name" = "PowerShell EnableWinRM Script"
            }
            "content"   = "$main_contents"
        }

        # Convert the Body to JSON for the RestMethod
        $create_body = $create_body | ConvertTo-Json
        $body
        $token = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
        $url = "https://api.github.com/repos/$owner/$repo/contents/$path"

        # Convert the token to base64 for the RestMethod
        $base64Token = [System.Convert]::ToBase64String([char[]]$token)
        $headers = @{
            Authorization = 'Basic {0}' -f $base64Token
            # Accept = 'application/vnd.github.v4.raw
        };
         if($flag -eq 'no'){
        # RestMethod to create the new file in the Repo
        $result = Invoke-RestMethod  -Method PUT  -Headers $headers  -Body $create_body -Uri $url -ContentType 'Application/json'
        $result
         }
         else{
            # Do nothing
            write-output "This server was aleady noted in the Repo. No need to repeat."
         }
    }
}
Function send_email($server,$ip) {
######################################################################################################################
#======================================================================
# Send email message when PowerShell is less than version 3
#======================================================================
# Email To/From/Subject/Body
write-output "The server's Powershell version is less than 3.0"
write-output "Sending Email to xxxxxxxxxxxx group"

$From = "xxxxxxxxxxxxx <xxxxxxx@xxxxxxxxxxx.com>"
$To = "xxxxxxxxxxx Team <xxxxxxxxxx@xxxxxxxxxx.com>"
$Subject = "Server has Powershell less than 3.0"
$Body = "Server $server ($ip) has a Powershell version less than 3.0. Please add to the JIRA sprint and upgrade."
$SMTPServer = "xxxxxxxx.xxxxxxxxxxx.com"

# Send email
Send-MailMessage -From $From -to $To -Subject $Subject `
-Body $Body -SmtpServer $SMTPServer  
}
######################################################################################################################
Function config_remote() {
    #======================================================================
    # Check and make sure WMI service is running automatically
    #======================================================================
    $wmi_status = Get-Service winmgmt
    if ($wmi_status.status -ne "Running") {
        Write-Output "The WMI service is not running. The service will be started."
        start-service winmgmt
        Write-Output "The WMI service has been restarted."
        Write-Output "Setting WMI to automatic startup"
        Set-Service -Name winmgmt -ComputerName . -StartupType Automatic
    }
    Else {
        Write-Output "The WMI service is already running"
    }
    $wmi_mode = Get-Service winmgmt | select-Object  -Property Name, StartType
    if ($wmi_mode.StartType -ne "Automatic") {
        Write-Output "The WMI service has not been set to start automatically."
        Set-Service -Name winmgmt -ComputerName . -StartupType Automatic
        Write-Output "The WMI service has been set to start automatically."
    }
    Else {
        Write-Output "The WMI service is already set to start automatically."
    }
    #======================================================================
    # Check WinRM service and if not present then configure and start
    #=====================================================================
    Write-Output "Verifying WinRM service"
    $WinRM = Get-Service -Name "WinRM"
    if ($WinRM.Status -eq "Running") {
        Write-Output "The WinRM service is present and running"
        $winrm_mode = Get-Service  WinRM | select-Object -Property Name, StartType
        if ($winrm_mode.StartType -ne "Automatic") {
            Write-Output "Setting WinRM service to run automatically"
            Set-Service -Name WinRM -ComputerName . -StartupType Automatic
        }
        Else {
            Write-Output "WinRM already set to run automatically"
        }
        $port = Get-item wsman:\localhost\listener\*\Port
        if ($port.Value -ne 5985) {
            Write-Output "Switching default Port to 5985"
            Set-item wsman:\localhost\listener\*\Port 5985  -Force
            Write-Output "Restarting WinRM"
            Restart-Service WinRM
            $port = Get-item wsman:\localhost\listener\*\Port
            Write-Output "The new default port for WinRM is $($port.Value)"
            netstat -na | findstr :$($port.Value)
            winrm get winrm/config/service
            winrm quickconfig  -Force
            Set-item wsman:\localhost\service\auth\Basic true
            Set-item wsman:\localhost\client\auth\Basic true
            Write-Output "Checking if anyone of the network connections are public"
            $net = Get-NetConnectionProfile
            if ($net.NetworkCategory -eq "Public") {
                Write-Output "Skipping WSMan AllowUnencrypted = true"
            }
            Else {
                Set-item wsman:\localhost\service\AllowUnencrypted true
            }
        }
        Else {
            Write-Output "The default port is already $($port.Value)"
        }
    }
    Else {
        Start-Service WinRM
        Write-Output "Setting WinRM service to run automatically"
        Set-Service -Name WinRM -ComputerName . -StartupType Automatic
        Write-Output "Checking WinRM Transport config"
        $listener = winrm get winrm/config/Listener?Address=*+Transport=HTTP
        if ($listener) {
            Write-Output "WinRM config already exists"
            winrm delete winrm/config/Listener?Address=*+Transport=HTTP
            $listener = winrm create winrm/config/Listener?Address=*+Transport=HTTP
            $listener
        }
        Else {
            $listener = winrm create winrm/config/Listener?Address=*+Transport=HTTP
            $listener
        }
        Write-Output = "Checking to see if PSRemoting is enabled"
        $PSEnable = Get-Childitem WSMan:\localhost\Listener
        if ($PSEnable.Type -ne "Container") {
            Enable-PSRemoting -Force
            Write-Output "PSRemoting will be enabled"
        }
        Else {
            Write-Output = "PSRemoting is already enabled"
        }   
    }
}
#======================================================================
# Check for the version of PowerShell and report any server having less
# than version 3.0
#======================================================================
$ver = $PSVersionTable.PSVersion
$ip = get-WmiObject Win32_NetworkAdapterConfiguration| Where {$_.IPAddress} | Select -Expand IPAddress
if ($ver.Major -gt 3 -and $ver.Major -lt 5) {
    Write-Output "This server's version of Powershell is above 3.0 but can be upgraded to the latest"
    Write-Output "Adding server name to list in repository"
    $hostname = $env:computername
    update_repo $hostname $ver.Major
    config_remote
}
Elseif($ver.Major -lt 3){
    $hostname = $env:computername
    send_email $hostname $ip
}
Else{
    Write-Output "Server's Powershell version is sufficient at version $($ver.Major)"
    config_remote
}

