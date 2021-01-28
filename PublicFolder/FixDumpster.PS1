
$ParentPath = "\"

$DeletePath = "\NON_IPM_SUBTREE\DUMPSTER_ROOT\DUMPSTER_EXTEND\RESERVED_1\RESERVED_1"

# $session = Get-PSSession -InstanceId (Get-OrganizationConfig).RunspaceId.Guid
# Invoke-Command -Session $session -ScriptBlock { get-publicfolder $Folder -recurse -resultsize unlimited } -ArgumentList $Folder
$Dumpstermismatch = @()
$Folders = get-publicfolder $ParentPath -recurse -resultsize unlimited
$DumpsterDir =  get-publicfolder "\NON_IPM_SUBTREE" -recurse -resultsize unlimited
#$dumpsterPre = $DumpsterDir | select entryID,DumpsterEntryID

$stopwatch =  [system.diagnostics.stopwatch]::StartNew()
$count = 0 ; $total = $folders.Count ; $Folders.Count ; $DumpsterDir.count
foreach ($F in $folders) {   $Dumpster = @() ; $DID = @() ;
               #$Folder = get-publicfolder -identity $F.EntryID ; 
               #$DumpsterEntryID = $Folder.DumpsterEntryID
               $DID = $F.DumpsterEntryID
               #$Dumpster = Get-Publicfolder -identity $DID -EA silentlycontinue
               $Dumpster = $DumpsterDir.Where({ $F.DumpsterEntryID -eq $_.EntryID })
        If ($Dumpster) { Write-Host "Dumpster" $DID "- Folder" $($F.entryID) "Found" -F cyan }
                  Else { Update-PublicFolderMailbox $F.ContentMailboxGuid.Guid -FolderId $F.EntryID -CreateAssociatedDumpster -InvokeSynchronizer -Confirm:$false ; 
                         sleep 20 ; $Dumpster = Get-Publicfolder -identity $DID -EA silentlycontinue }

        If ($F.ContentMailboxGuid.Guid -eq $Dumpster.ContentMailboxGuid.Guid) {
                   Write-host "Folder/Dumpster same Content Mailbox - OK" -F green }
            Else { Write-host "Folder/Dumpster - different  Content Mailbox" -F yellow ;
                   Update-PublicFolderMailbox $F.ContentMailboxGuid.Guid -FolderId $F.EntryID -InvokeSynchronizer -Confirm:$false }

            $Dumpsterparent = $Dumpster.ParentPath
        If ($Dumpsterparent -like "\NON_IPM_SUBTREE*" ) {
                   Write-host "Dumpster Parent correct" -F green ;}
      Else {       Write-host "Dumpster Parent not in NON_IPM_SUBTREE" -F Yellow
             try { Set-Publicfolder -identity $DID -path $DeletePath -EA STOP } 
           catch { $error[0].Exception | fl * }
           }

        If ($Dumpster.DumpsterEntryId -eq $F.EntryId) { 
                   Write-host "No Dumpster Mismatch OK" -F green }
      Else {       Write-host "Dumpster REVERSE Mismatch" -F yellow ; $Dumpstermismatch += $F
                   #Update-PublicFolderMailbox $Folder.ContentMailboxGuid.Guid -FolderId $Folder.EntryID -CreateAssociatedDumpster -InvokeSynchronizer -Confirm:$false
                   #Update-PublicFolderMailbox $Folder.ContentMailboxGuid.Guid -ForceOnlineSync -ReconcileFolders -InvokeSynchronizer -Confirm:$false
           }

    # estimate the time remaining
    $count++
    $secondsRemaining = (($stopwatch.ElapsedMilliseconds/1000)/$count) * ($total – $count)
    $seconds = $stopwatch.ElapsedMilliseconds/1000
    $percentComplete = ($count / $total) * 100
    $progressParameters = @{ Status = 'Processing'
        Activity = "Doing my thing [$count/$total] $seconds"
        CurrentOperation = "Doing something with $F"
        PercentComplete = $percentComplete
        SecondsRemaining = $secondsRemaining }
        Write-Progress @progressParameters

}
