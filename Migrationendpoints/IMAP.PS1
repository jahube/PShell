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

# Reference - Ports: IMAP(no ssl)143 (IMAP/TLS)993 (SMTP)587 (SSL)443

New-MigrationEndpoint -IMAP -Name $EndpointName -RemoteServer $IMAPserver -Port $Port -Security $security

get-MigrationEndpoint $EndpointName | % { Test-MigrationServerAvailability -Imap -RemoteServer $_.RemoteServer -Port 993 }

Test-MigrationServerAvailability -Imap -RemoteServer $IMAPserver -Port $Port

####       remove syncrequest        ####
Get-Syncrequest -mailbox "USER HERE" | Remove-syncrequest

#### Misc
Get-MigrationUser | Set-MigrationUser -SyncNow
Set-MigrationBatch -Identity MigrationBatch01 -SyncNow
Set-MigrationBatch -Identity MigrationBatch01 -ApproveSkippedItems

####  remove failed migrationusers   ####
$failedusers =  get-migrationuser | where { $_.status -eq 'failed' }
$failedusers | % { remove-migrationuser -identity $_.identity -force -confirm:$true }

####        remove batch             ####
 remove failed batches
$failedmigrationbatch =  get-MigrationBatch | where { $_.status -eq 'failed' }
$failedmigrationbatch | % { remove-MigrationBatch -identity $_.identity.ToString() -CF:$true }

 remove aready completed batches
$failedmigrationbatch =  get-MigrationBatch | where { $_.status -eq 'Completed' }
$failedmigrationbatch | % { remove-MigrationBatch -identity $_.identity.ToString() -CF:$true }


  Set Completion time for synced with errors
$failedmigrationbatch =  get-MigrationBatch | where { $_.status -eq 'CompletedWithErrors' }
$failedmigrationbatch |% { Set-MigrationBatch -identity $_.identity.ToString() -CompleteAfter (Get-Date).ToUniversalTime() -CF:$true }

 Set Completion time
$failedmigrationbatch =  get-MigrationBatch | where { $_.status -eq 'synced' }
$failedmigrationbatch | % { Set-MigrationBatch -identity $_.identity.ToString() -CompleteAfter (Get-Date).ToUniversalTime() -CF:$true }

 manual complete
$failedmigrationbatch =  get-MigrationBatch | where { $_.status -eq 'synced' }
$failedmigrationbatch | % { Complete-MigrationBatch -identity $_.identity.ToString() -SyncAndComplete -CF:$true }


