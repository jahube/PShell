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

- common issue - orphan IMAP sync request -
 >>  remove syncrequest
Get-Syncrequest -mailbox "USER HERE" | Remove-syncrequest

- check if you want to resume or remove the failed users / batches
 >>  Misc
Get-MigrationUser | Set-MigrationUser -SyncNow
Set-MigrationBatch -Identity MigrationBatch01 -SyncNow
Set-MigrationBatch -Identity MigrationBatch01 -ApproveSkippedItems

 >>  remove failed migrationusers
Foreach ($MigUser in (get-migrationuser).where({$_.status -eq 'failed'})) {
remove-migrationuser -identity $MigUser.identity.ToString() -CF:$true }

 >> remove failed batches
Foreach ($Batch in (get-MigrationBatch).where({$_.status -eq 'failed'})) {
remove-MigrationBatch -identity $Batch.identity.ToString() -CF:$true }

 >> remove aready completed batches
Foreach ($Batch in (get-MigrationBatch).where({$_.status -eq 'Completed'})) {
remove-MigrationBatch -identity $Batch.identity.ToString() -CF:$true }

 >>  Set Completion time for 'CompletedWithErrors'
Foreach ($Batch in (get-MigrationBatch).where({$_.status -eq 'CompletedWithErrors'})) {
Set-MigrationBatch -identity $Batch.identity.ToString() -CompleteAfter (Get-Date).ToUniversalTime() -CF:$true }

 >> Set Completion time
Foreach ($Batch in (get-MigrationBatch).where({$_.status -eq 'synced'})) {
Set-MigrationBatch -identity $Batch.identity.ToString() -CompleteAfter (Get-Date).ToUniversalTime() -CF:$true }

 >> manual complete + final sync
Foreach ($Batch in (get-MigrationBatch).where({$_.status -eq 'synced'})) {
Complete-MigrationBatch -identity $Batch.identity.ToString() -SyncAndComplete -CF:$true }
