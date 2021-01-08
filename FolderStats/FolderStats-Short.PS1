#   Folderstats - NEW - should work also for inactive

$admin = "admin@domain.com" #  <-- Modify

$USER = "affected user"     #  <-- Modify

Install-Module -Name ExchangeOnlineManagement

Connect-ExchangeOnline -UserPrincipalName $admin -ShowProgress $true

$user = (get-mailbox $USER -IncludeInactiveMailbox).distinguishedname

$types = "RecoverableItemsDeletions","RecoverableItemsPurges","Inbox","Outbox","SentItems","Drafts","JunkEmail","Archive","Contacts","Calendar","Notes","QuickContacts","RecipientCache","User Created","RecoverableItemsDiscoveryholds","RecoverableItemsRoot"

$stats = (Get-MailboxFolderStatistics $user -IncludeSoftDeletedRecipients).where( {$_.foldertype.tostring() -in ($types)})
$filtered = $stats | Select Name,containerclass,foldertype, `
@{name=”Folderandsubfoldersize (MB)”; expression={[math]::Round( `
($_.Folderandsubfoldersize.ToString().Split(“(“)[1].Split(” “)[0].Replace(“,”,””)/1MB),2)}},
Itemsinfolderandsubfolders,oldestitemreceiveddate | Sort “Folderandsubfoldersize (MB)” -Descending

$filtered | ft