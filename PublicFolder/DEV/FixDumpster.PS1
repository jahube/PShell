  
Start-transcript

$Folder = "\"

$Folders = get-publicfolder $Folder -recurse -resultsize unlimited

foreach ($F in $Folders) { $Dumpster = @() ; $DumpsterEntryID = @()
$Folder = get-publicfolder -identity $F.EntryID ; $DumpsterEntryID = $Folder.DumpsterEntryID
$Dumpster = Get-Publicfolder -identity $DumpsterEntryID -EA silentlycontinue
If (!($Dumpster)) { Update-PublicFolderMailbox $Folder.ContentMailboxGuid.Guid -FolderId $Folder.EntryID -CreateAssociatedDumpster -InvokeSynchronizer -Confirm:$false }
If ($Dumpster) { Write-Host "Dumpster" $DumpsterEntryID "- Folder" $($folder.entryID) "Found" -F cyan

$Dumpsterparent = $Dumpster.ParentPath ; If ($Dumpsterparent -like "\NON_IPM_SUBTREE*" ) {Write-host "Dumpster Parent correct" -F green ;}

If ($Folder.ContentMailboxGuid.Guid -eq $Dumpster.ContentMailboxGuid.Guid) {Write-host "Dumpster Content Mailbox - No Mismatch OK" -F green }
If ($Folder.ContentMailboxGuid.Guid -ne $Dumpster.ContentMailboxGuid.Guid) {Write-host "Dumpster Content Mailbox - Mismatch" -F yellow ;
Update-PublicFolderMailbox $Folder.ContentMailboxGuid.Guid -FolderId $Folder.EntryID -CreateAssociatedDumpster -InvokeSynchronizer -Confirm:$false

If ($Dumpsterparent -notlike "\NON_IPM_SUBTREE*") {Write-host "Wrongparent" -F Yellow ;
try { Set-Publicfolder -identity $DumpsterEntryID -path $DeletePath -EA STOP } catch { $error[0].Exception | fl * }}
If ($Dumpster.DumpsterEntryId -eq $folderitem.EntryId) {Write-host "No Dumpster Mismatch OK" -F green }
If ($Dumpster.DumpsterEntryId -ne $folderitem.EntryId) {Write-host "Dumpster REVERSE Mismatch" -F yellow ;
#Update-PublicFolderMailbox $Folder.ContentMailboxGuid.Guid -FolderId $Folder.EntryID -CreateAssociatedDumpster -InvokeSynchronizer -Confirm:$false
#Update-PublicFolderMailbox $Folder.ContentMailboxGuid.Guid -ForceOnlineSync -ReconcileFolders -InvokeSynchronizer -Confirm:$false}}}

Stop-transcript