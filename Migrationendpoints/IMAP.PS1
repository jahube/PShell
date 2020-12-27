$EndpointName = "T-Online-IMAP-Endpoint"
$IMAPserver = "secureimap.t-online.de"  # imapmail.t-online.de
$Port = "993" ; $security = "Ssl"

$EndpointName = "IONOS-IMAP-Endpoint" # https://www.ionos.com/help/email/email-migration-service/migrating-emails-and-folders-from-an-external-email-provider-to-ionos/
$IMAPserver = "imap.ionos.de" 
$Port = "993" ; $security = "Ssl"

$EndpointName = "GMX-IMAP-Endpoint" # Enable IMAP first // https://hilfe.gmx.net/pop-imap/einschalten.html
$IMAPserver = "imap.gmx.com"
$Port = "993" ; $security = "Ssl"

$EndpointName = "GMAIL-IMAP-Endpoint"
$IMAPserver = "imap.gmail.com"
$Port = "993" ; $security = "Ssl" 

New-MigrationEndpoint -IMAP -Name $EndpointName -RemoteServer $IMAPserver -Port $Port -Security $security

get-MigrationEndpoint $EndpointName | % { Test-MigrationServerAvailability -Imap -RemoteServer $_.RemoteServer -Port 993 }

Test-MigrationServerAvailability -Imap -RemoteServer $IMAPserver -Port $Port




# Ports: IMAP(no ssl)143 (IMAP/TLS)993 (SMTP)587 (SSL)443