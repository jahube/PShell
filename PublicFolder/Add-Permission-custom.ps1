################################################################
#        Change the PATH - RECURSIVE (INCL SUBFOLDER)          #
################################################################
$folderscope = '\'                                             # **MODIFY**
################################################################
# CHOOSE PERMISSION:     Owner, Editor, Reviewer, Author       #
################################################################
$permission = 'Owner'                                          # **MODIFY**
################################################################
# ALTERNATIVE: CUSTOM LIST OF PERMISSION TAGS
# $permission = 'CreateItems','ReadItems','CreateSubfolders','FolderOwner','FolderContact','FolderVisible','EditOwnedItems','EditAllItems' ;
################################################################
$user = "Accessing@Mailbox.com"                                # **MODIFY**
################################################################
$access = (Get-mailbox -Identity $user).Distinguishedname
################################################################
# security group ALTERNATIVE
# $Group = 'security group displayname'
# $access = (Get-DistributionGroup $Group).Distinguishedname ;
################################################################
$PFs = get-publicfolder $folderscope -Recurse -ResultSize unlimited -EA silentlycontinue ;
[System.Collections.ArrayList]$PFE = ($PFs).entryid
$count = $PFE.count
for ($F = 0; $F -lt $PFE.count; $F++) { 
Write-Progress -Activity "Add pemission ($permission) - current Folder" -Id 2 -ParentId 1 -Status $PFE[$F] -PercentComplete (($F/$count)*100) -SecondsRemaining (($count-$F)*3) ;
Add-PublicFolderClientPermission -Identity $PFE[$F] -user $access -AccessRights $permission -Confirm:$false }
################################################################
