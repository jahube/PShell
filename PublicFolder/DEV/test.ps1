$folders = Get-PublicFolder \ -Recurse
$delete = $folders | where { $_.name -match "Test22" }
$delete | fl entryid,ParentFolder,FolderPath,*dumpster*

Get-PublicFolder $delete.EntryId -Recurse | ?{$_.FolderClass -eq "IPF.Note"} 
Get-PublicFolder $delete.DumpsterEntryId -Recurse | ?{$_.FolderClass -eq "IPF.Note"} 

$items = Get-PublicFolder \ -Recurse | Get-PublicFolderItemStatistics | ?{$_.ItemType -eq "IPM.Note"} 
$items

$itemsdeleted = @()
Foreach ($F in $folders)

$founddeleted = Get-PublicFolder $delete.DumpsterEntryId -Recurse | Get-PublicFolderItemStatistics | ?{$_.ItemType -eq "IPM.Note"}
IF ($founddeleted) { $itemsdeleted += $founddeleted ; Write-host ""}

Remove-PublicFolder '\Test\Test-Test1\Test-Test1-Test1'
Write-host $Error[0].Exception.Message -F Yellow

$deleted = Get-PublicFolder \NON_IPM_SUBTREE\DUMPSTER_ROOT -Recurse | ?{$_.FolderClass -eq "IPF.Note"} 


Foreach ($D in $delete) { Try {
Remove-PublicFolder -Identity $D.entryID -Recurse -CF:$false -EA stop
Write-host "$($D.identity) deleted" -F green } catch {
Write-host "$($D.identity) failed" -F Yellow } }


$newitems = New-PublicFolder -Name restoredItems -Path \

$deleteditems = Get-PublicFolder \NON_IPM_SUBTREE\DUMPSTER_ROOT -Recurse | Get-PublicFolderItemStatistics | ?{$_.ItemType -eq "IPM.Note"} 
$dumpsterfolders = Get-PublicFolder \NON_IPM_SUBTREE\DUMPSTER_ROOT -Recurse
$dumpsterfolders | get-member

$dumpsterfolders | ft *EntryId*,name
$deleteditems| ft *EntryId*,name

Foreach ($DF in $dumpsterfolders) {

$match = $DF | where { $DF.DumpsterEntryId -in $folders } 

Get-PublicFolder "\restored\Allegro - 2017 to Q1 2018" | fl
Remove-PublicFolder "\restored\Allegro - 2017 to Q1 2018"
Get-PublicFolder \NON_IPM_SUBTREE\DUMPSTER_ROOT -Recurse | where { $_.
$deletedfol = Get-PublicFolder \NON_IPM_SUBTREE\DUMPSTER_ROOT -Recurse | ?{$_.FolderClass -eq "IPF.Note"} 
$deletedfol | where { $_.name -eq "Allegro - 2017 to Q1 2018" } | select -ExpandProperty folderpath