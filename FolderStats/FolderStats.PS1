# NEW Folderstats sorted Filtered

$user = (get-mailbox USER).distinguishedname

$types = "RecoverableItemsDeletions","RecoverableItemsPurges","Inbox","Outbox","SentItems","Drafts","JunkEmail","Archive","Contacts","Calendar","Notes","QuickContacts","RecipientCache","User Created","RecoverableItemsDiscoveryholds","RecoverableItemsRoot"

$stats = (Get-MailboxFolderStatistics $user).where( {$_.foldertype.tostring() -in ($types)})
$filtered = $stats | Select Name,containerclass,foldertype, `
@{name=”Folderandsubfoldersize (MB)”; expression={[math]::Round( `
($_.Folderandsubfoldersize.ToString().Split(“(“)[1].Split(” “)[0].Replace(“,”,””)/1MB),2)}},
Itemsinfolderandsubfolders,oldestitemreceiveddate | Sort “Folderandsubfoldersize (MB)” -Descending
$filtered | ft

# OLD - Folderstats all 1
$user = (get-mailbox USER).distinguishedname
Get-MailboxfolderStatistics $user | Select Name,containerclass,foldertype, `
@{name=”Folderandsubfoldersize (MB)”; expression={[math]::Round( `
($_.Folderandsubfoldersize.ToString().Split(“(“)[1].Split(” “)[0].Replace(“,”,””)/1MB),2)}},
Itemsinfolderandsubfolders | Sort “Folderandsubfoldersize (MB)” -Descending | ft

# OLD - Folderstats all 2
$user = (get-mailbox USER).distinguishedname
$stats = ICM { Get-MailboxFolderStatistics -Identity $user -includeoldestandnewestitems -folderscope NonIPMRoot }
$filtered = $stats | Select Name,containerclass,foldertype, `
@{name=”Folderandsubfoldersize (MB)”; expression={[math]::Round( `
($_.Folderandsubfoldersize.ToString().Split(“(“)[1].Split(” “)[0].Replace(“,”,””)/1MB),2)}},
Itemsinfolderandsubfolders,oldestitemreceiveddate | Sort “Folderandsubfoldersize (MB)” -Descending
$filtered | ft