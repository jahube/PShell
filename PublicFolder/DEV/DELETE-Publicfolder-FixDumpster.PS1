Start-transcript

$DeleteFolder = "\Folder\to\delete"

$Folders = get-publicfolder $DeleteFolder -recurse
$DeletePath = "\NON_IPM_SUBTREE\DUMPSTER_ROOT\DUMPSTER_EXTEND\RESERVED_1\RESERVED_1"
foreach ($F in $Folders) { $Found = @() ; $DumpsterEntryID = @()
$Folder = get-publicfolder -identity $F.EntryID ; $Folder | FL ; Get-publicfolderstatistics $F.EntryID | FL
$DumpsterEntryID = $Folder.DumpsterEntryID ; try { get-publicfolderstatistics $DumpsterEntryID |FL } catch { $error[0].Exception | fl * }
try {$Found = Get-Publicfolder -identity $DumpsterEntryID -EA Stop; $Found | FL  } catch { $error[0].Exception | fl * }
If ($Found) { Write-Host "Dumpster" $DumpsterEntryID "- Folder" $($folder.entryID) "Found" -F cyan
try { Set-Publicfolder -identity $DumpsterEntryID -path $DeletePath -EA STOP } catch { $error[0].Exception | fl * }
try { Remove-Publicfolder -identity $F.EntryID -CF:$false } catch { $error[0].Exception | fl * }}
$notdeleted = get-publicfolder -identity $F.EntryID -EA silentlycontinue
If ($notdeleted) {  try { Set-Publicfolder -identity $F.EntryID -Path $DeletePath -CF:$false } catch {  $error[0].Exception | fl * }}  }


# Create new test PF under IPM and see if you can remove it

$DeleteFolder = "\DeleteTest"
New-PublicFolder -Name $DeleteFolder -Path \
Get-PublicFolder $DeleteFolder
Remove-PublicFolder $DeleteFolder
$error[0].Exception | fl *
Get-PublicFolder $DeleteFolder

Stop-transcript