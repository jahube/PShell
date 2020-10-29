
$folderscope = '\' ;

$permission = 'Editor' ;

# security group
$Group = 'security group displayname' 
$access = (Get-DistributionGroup $Group).Distinguishedname ;

# user mailbox
$user = "admin@domain.com"
$access = (Get-mailbox -Identity $user).Distinguishedname ;


$PFs = get-publicfolder $folderscope -Recurse -ResultSize unlimited -EA silentlycontinue ;

$count = $PFs.count
for ($F = 0; $F -lt $PFs.count; $F++) { 

Write-Progress -Activity "Add pemission ($permission) - current Folder" -Id 2 -ParentId 1 -Status $($PFs[$F].identity) -PercentComplete (($F/$count)*100) -SecondsRemaining ($count-$F) ;

Add-PublicFolderClientPermission -Identity $PFs[$F].entryid -user $access -AccessRights $permission -Confirm:$false ;

}