
##################################
# recover deleted Public folders #
##################################

$new = New-PublicFolder -Name Restored -Path \

$deleted = Get-PublicFolder \NON_IPM_SUBTREE\DUMPSTER_ROOT -Recurse | ?{$_.FolderClass -eq "IPF.Note"} 

foreach ($d in $deleted) { Set-PublicFolder -Identity $d.EntryId -Path $new.EntryId }

##################################################################
#items ** EXPERIMENTAL ** DON'T USE except in a test environment #
##################################################################

$newitems = New-PublicFolder -Name restoredItems -Path \

$deleteditems = Get-PublicFolder \NON_IPM_SUBTREE\DUMPSTER_ROOT -Recurse | Get-PublicFolderItemStatistics | ?{$_.ItemType -eq "IPM.Note"} 

foreach ($D in $deleteditems) { Set-PublicFolder -Identity $D.EntryId -Path $newitems.EntryId }

#################################
#  Restore deleted PF Mailboxes #
#################################

get-mailbox -publicfolder -softdeletedmailbox

get-mailbox -publicfolder -softdeletedmailbox | undo-softdeletedmailbox 

Get-PublicFolder -LostAndFound  | PublicFolderItemStatistics |fl