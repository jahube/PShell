# Folder permissions in OWA
#-------------------------

$access = 'Reviewer'

$MBX = "mailbox@to.share" # please modify

$user = "user@gets.access" # please modify

$inbox = "Inbox"

$customfolder = "Posteingang"

# Add Root Permission - REQUIRED
Try { Add-MailboxFolderPermission -identity $MBX -User $user -Accessrights Reviewer -EA stop } catch { write-host $Error[0].Exception.message -F yellow }

# Add Inbox Permission
Try { Add-MailboxFolderPermission -identity $($MBX+':\'+$inbox) -User $user -Accessrights Reviewer -EA stop } catch { write-host $Error[0].Exception.message -F yellow }

# Add customfolder Permission
Try { Add-MailboxFolderPermission -identity $($MBX+':\'+$customfolder) -User $user -Accessrights Reviewer -EA stop } catch { write-host $Error[0].Exception.message -F yellow }


# Add Permission to all foldertypes below
$types = "Inbox","Outbox","SentItems","Drafts","JunkEmail","Archive","Contacts","Calendar","Notes","QuickContacts","RecipientCache","User Created"

foreach($F in (Get-MailboxFolderStatistics $MBX | ? {$_.foldertype.tostring() -in ($types)})){ $FN = $MBX + ':' + $F.FolderPath.Replace('/','\');
Try { Add-MailboxFolderPermission $FN -User $user -AccessRights $access -EA stop } catch { write-host $Error[0].Exception.message -F yellow }}