  
Start-transcript

$DeleteFolder = "\"

$Folders = get-publicfolder $DeleteFolder -recurse
$DeletePath = "\NON_IPM_SUBTREE\DUMPSTER_ROOT\DUMPSTER_EXTEND\RESERVED_1\RESERVED_1"

foreach ($F in $Folders) { 

$Found = @() ; $DumpsterEntryID = @()

try { Remove-Publicfolder -identity $F.EntryID -CF:$false -EA stop } catch { $error[0].Exception | fl * }

$notdeleted = get-publicfolder -identity $F.EntryID -EA silentlycontinue

If ($notdeleted) {  
try { Set-Publicfolder -identity $F.EntryID -Path $DeletePath -CF:$false -EA stop } catch {  $error[0].Exception | fl * }
                 }
                         }

# Create new test PF under IPM and see if you can remove it

$DeleteFolder = "DeleteTest"
$Test = New-PublicFolder -Name $DeleteFolder -Path \
Get-PublicFolder $Test.entryID
Remove-PublicFolder $Test.entryID
$error[0].Exception | fl *
Get-PublicFolder $Test.entryID

Stop-transcript 
