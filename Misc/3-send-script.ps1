Set-ExecutionPolicy RemoteSigned -Force

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Install-Module-ExchangeonlineManagement

Connect-Exchangeonline -userprincipalname "admin@domain.com"

1.a) # Standard Version
-------------------------------------------------------------------------------------

$TO = "Recipient@domain.com"

$FROM = "Sender@domain.com"

$Cred = get-credential $From         # <-- Provide sender's credentials when prompt 

$Body = "This is the body of test message. The message was sent on: $(get-date)"

<# alternative
$Body = @'
<!DOCTYPE html>
<html>
<head>
</head>
<body>
This is a test message to trigger an ETR.

The message was sent on: $(get-date)
</body>
</html>
'@
alternative #>

$Param = @{  to = $TO
           from = $FROM
     smtpserver = "smtp.office365.com"
           port = "587"
        subject = "SMTP - Client submission - 587"
           body = "This is the body of test message. The message was sent on: $(get-date)"
     Credential = $Cred
         UseSsl = $true
     BodyAsHtml = $true }

Send-mailmessage $Param

write-host "Sending Message..."

# Collect output in a TXT file if it fails)
-------------------------------------------------------------------------------------
2) # extended Version 
-------------------------------------------------------------------------------------
$Credential = (Get-Credential)
$PARAM = @{ From = "SENDER@YourDomain.Com"
              To = "First@Recipient.com", "Second@Recipient.com"
              Cc = "Other@Recipient.com"
     Attachments = "C:\Temp\Attachment.jpg"
         Subject = "Photos attached"
      SmtpServer = "smtp.office365.com"
            Port = "587"
          UseSsl = $true
      BodyAsHtml = $true
         Verbose = $true }

$Body = @'
<!DOCTYPE html>
<html>
<head>
</head>
<body>
This is a test message to trigger an ETR.
</body>
</html>
'@

Send-MailMessage @Param -Body $Body -Credential $Credential

-------------------------------------------------------------------------------------
3) .NET Send Method #1         # Source https://www.undocumented-features.com/2018/05/22/send-authenticated-smtp-with-powershell/
-------------------------------------------------------------------------------------
# Sender and Recipient Info
$MailFrom = "sender@senderdomain.com"
$MailTo = "recipient@recipientdomain.com"

# Sender Credentials
$Username = "SomeUsername@SomeDomain.com"
$Password = "SomePassword"

# Server Info
$SmtpServer = "smtp.office365.com"
$SmtpPort = "587"

# Message stuff
$MessageSubject = "Live your best life now" 
$Message = New-Object System.Net.Mail.MailMessage $MailFrom,$MailTo
$Message.IsBodyHTML = $true
$Message.Subject = $MessageSubject
$Message.Body = @'
<!DOCTYPE html>
<html>
<head>
</head>
<body>
This is a test message to trigger an ETR.
</body>
</html>
'@

# Construct the SMTP client object, credentials, and send
$Smtp = New-Object Net.Mail.SmtpClient($SmtpServer,$SmtpPort)
$Smtp.EnableSsl = $true
$Smtp.Credentials = New-Object System.Net.NetworkCredential($Username,$Password)
$Smtp.Send($Message)

-------------------------------------------------------------------------------------
4) .NET Send Method #Alternative
-------------------------------------------------------------------------------------
#Ask for credentials and store them
$credential = Get-Credential
$credential.Password | ConvertFrom-SecureString | Set-Content C:\Passwords\scriptsencrypted_password1.txt
# Read encrypted password
$encrypted = Get-Content C:\Passwords\scriptsencrypted_password1.txt | ConvertTo-SecureString
# Set variables
$emailusername = "Email@domain.com"
$credential = New-Object System.Management.Automation.PsCredential($emailusername, $encrypted)
# Email parametres

# $Body = "Test email. This is a notification from Powershell."

$Body = @'
<!DOCTYPE html>
<html>
<head>
</head>
<body>
This is a test message to trigger an ETR.
</body>
</html>
'@

$Subject = "Powershell Notification"
$EmailFrom = "Email@domain.com"
$EmailTo = "Email@domain.com"
$SMTPServer = "smtp.office365.com"
$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587)
$SMTPClient.EnableSsl = $true
$SMTPClient.Credentials = $credential;
# Send email
$SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)

-------------------------------------------------------------------------------------
# Example to store credentials
-------------------------------------------------------------------------------------

# ADMINCredential
Get-Credential $ADMIN | Export-Clixml $ENV:UserProfile\Documents\ADMINCredential.xml
$ADMINcred = Import-Clixml $ENV:UserProfile\Documents\ADMINCredential.xml

# FROM Credential
Get-Credential $FROM | Export-Clixml $ENV:UserProfile\Documents\FROMCredential.xml
$FROMcred = Import-Clixml $ENV:UserProfile\Documents\FROMCredential.xml