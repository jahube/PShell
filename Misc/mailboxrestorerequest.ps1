wget https://aka.ms/hybridconnectivity -OutFile c:\tm.psm1
Import-Module c:\tm.psm1
Test-HybridConnectivity -TestO365Endpoints
get-mailbox -SoftDeletedMailbox | Get-MailboxFolderStatistics -IncludeSoftDeletedRecipients | fl *items*

get-mailbox 8f8eb835-c48c-41e1-ad88-c869a0dc920e | fl sam*
Get-Mailbox Jenn58241-1509788987




$source = "Abagael.C.Nestor@edu.dnsabr.com"
$target = "JenniferB@edu.dnsabr.com"

$MBX = Get-Mailbox -SoftDeletedMailbox $source
$TGT = Get-Mailbox $target

New-MailboxRestoreRequest -SourceMailbox $MBX.SamAccountName -TargetMailbox $TGT.SamAccountName -AllowLegacyDNMismatch

Aaron.A.Pauley   

$source = "Aaron.A.Pauley@edu.dnsabr.com"
$target = "HenryM@edu.dnsabr.com"

$MBX = (Get-Mailbox -SoftDeletedMailbox $source).DistinguishedName
$TGT = (Get-Mailbox $target).DistinguishedName
New-MailboxRestoreRequest -SourceMailbox $MBX.DistinguishedName -TargetMailbox $TGT.SamAccountName -AllowLegacyDNMismatch

$source = "Aaron.A.Pauley@edu.dnsabr.com"
$target = "HenryM@edu.dnsabr.com"
$param = @{ AllowLegacyDNMismatch = $true
SourceMailbox = (Get-Mailbox -SoftDeletedMailbox $source).DistinguishedName
TargetMailbox = (Get-Mailbox $target).DistinguishedName }
New-MailboxRestoreRequest @param

get-MailboxRestoreRequest | remove-MailboxRestoreRequest
Get-InboxRule -Mailbox admin@edu.dnsabr.com