$user = (get-EXOmailbox USERNAME).distinguishedname
$types = "RecoverableItemsDeletions","RecoverableItemsPurges","Inbox","Outbox","SentItems","Drafts","JunkEmail","Archive","Contacts","Calendar","Notes","QuickContacts","RecipientCache","User Created"
$stats = (Get-EXOMailboxFolderStatistics $user).where( {$_.foldertype.tostring() -in ($types)})
$filtered = $stats | Select Name,containerclass,foldertype, `
@{name=”Folderandsubfoldersize (MB)”; expression={[math]::Round( `
($_.Folderandsubfoldersize.ToString().Split(“(“)[1].Split(” “)[0].Replace(“,”,””)/1MB),2)}},
Itemsinfolderandsubfolders,oldestitemreceiveddate | Sort “Folderandsubfoldersize (MB)” -Descending
$filtered | ft