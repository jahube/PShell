################################################################
#        Change the PATH - RECURSIVE (INCL SUBFOLDER)          #
################################################################
$folderscope = '\'                                             # **MODIFY**
################################################################
$PFs = get-publicfolder $folderscope -Recurse -ResultSize unlimited -EA silentlycontinue ;
[System.Collections.ArrayList]$PFE = ($PFs).entryid ; $count = $PFE.count
for ($F = 0; $F -lt $PFE.count; $F++) { $A = "Setting <PerUserReadStateEnabled> - current Folder" ; $Prc= $(($F/$count)*100);
Write-Progress -Activity $A -Id 2 -ParentId 1 -Status $PFE[$F] -PercentComplete $Prc -SecondsRemaining ($count-$F);
Set-PublicFolder -Identity $PFE[$F] -PerUserReadStateEnabled:$true -Confirm:$false }
################################################################
