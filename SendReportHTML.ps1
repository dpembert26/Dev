# This is a PowerShell script that will send the ReportHTML file in email.

param(
        [string]$FilePath
)

$file = "report.html" 
$emailTo = @("xxxxxxxx xxxxxxxx <xxxxxxx.xxxxxxx@xxxxxxxxxx.com>", "xxxxxxxx xxxxxxxx <xxxxxxx.xxxxxxx@xxxxxxxxxx.com>", "xxxxxxxx xxxxxxxx <xxxxxxx.xxxxxxx@xxxxxxxxxx.com>",
    "xxxxxxxx xxxxxxxx <xxxxxxx.xxxxxxx@xxxxxxxxxx.com>", "xxxxxxxx xxxxxxxx <xxxxxxx.xxxxxxx@xxxxxxxxxx.com>")

$fullfile = join-path  -Path $FilePath $file 

$TestRes =  Test-path $fullfile

if($TestRes -eq "True"){
   try{ 
   write-output "The report.html file was located. Sending email to $emailTo "    
   $From = "ReportHTML File for Automated Test <xxxxxxxxx@xxxxxxxxx.com>"
   $To = $emailTo
   $Subject = "ReportHTML File for Automated Test"
   $Body = "The ReportHTML File for the Automated Test is attached to this email"
   $SMTPServer = "xxxxx.xxxxxxx.com"
   $SMTPPort = "25"

   Send-MailMessage -From $From -to $To -Subject $Subject `
   -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -Attachments $fullfile # -UseSsl `
   # -Credential $Cred 
   }
    catch {
         $ErrorMessage = $_.Exception.Message
         $ErrorMessage
    }

}
Else{
    write-output "The report.html file could not be found in the path $FilePath .Please check to see if the file exists."
}


 



