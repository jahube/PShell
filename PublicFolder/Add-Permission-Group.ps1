################################################################
#        Change the PATH - RECURSIVE (INCL SUBFOLDER)          #
################ (1) modifiy and run variables #################

$folderscope = '\' 

$permission = 'Owner'                                                      # other possible:  Editor, Reviewer, Author

$Group = 'change group name here'                                          # security group created in Exchange admincenter

$access = (Get-DistributionGroup $Group).Distinguishedname ; $access | FT  # if result empty edit the $Group = 'value' above

############### (2) run script #################################
$PFs = get-publicfolder $folderscope -Recurse -ResultSize unlimited -EA silentlycontinue ;
[System.Collections.ArrayList]$PFE = ($PFs).entryid ; $count = $PFE.count
for ($F = 0; $F -lt $PFE.count; $F++) { $A = "Add pemission ($permission) - current Folder" ; $Prc= $(($F/$count)*100);
Write-Progress -Activity $A -Id 2 -ParentId 1 -Status $PFE[$F] -PercentComplete $Prc -SecondsRemaining (($count-$F)*3);
Add-PublicFolderClientPermission -Identity $PFE[$F] -user $access -AccessRights $permission -Confirm:$false }
################################################################
