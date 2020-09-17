######################################################
#              Remove ALL Permissions                #
######################################################
$folderscope = '\'

$success = New-Object System.Collections.ArrayList
$errors = New-Object System.Collections.ArrayList
$PFs = get-publicfolder $folderscope –Recurse
$PS = $PFs | Get-PublicFolderClientPermission
$PS = $PS | ? { ($_.user.displayname -notmatch "Default") -and ($_.user.displayname -notmatch "Anonymous") }
$count = $PS.count
for ($P = 0; $P -lt $PS.count; $P++) { 
$F = $PS[$P].identity.ToString()
$DN = $PS[$P].user.displayname.ToString()
$DST = $PS[$P].user.RecipientPrincipal
$AR = $PS[$P].accessrights
$SPF = $PS[$P].SharingPermissionFlags
Write-Progress -Activity "Remove permission - [current Folder] $($F)" -Id 2 -ParentId 1 -Status "For [USER] $($DN)" -PercentComplete (($P/$count)*100) -SecondsRemaining $($count-$P) ;
Try { Remove-PublicFolderClientPermission $F -User $DN -Confirm:$false -EA 'stop' ; $success += $PS[$P]
 } catch {  Write-host $Error[0].Exception.Message -F yellow ; $errors += $PS[$P] } }

################## Anonymous #########################

$folderscope = '\'
Get-PublicFolder $folderscope -Recurse -ResultSize unlimited | Add-PublicFolderClientPermission -User Anonymous -AccessRights None -EA silentlycontinue

################## Default ###########################

$permission = "Author"

$folderscope = '\'

Get-PublicFolder $folderscope -Recurse -ResultSize unlimited | Add-PublicFolderClientPermission -User Default -AccessRights $permission -EA silentlycontinue

################### Owner ############################

$admin = get-mailbox admin@domain.com

$folderscope = '\'

Get-PublicFolder $folderscope -Recurse -ResultSize unlimited | Add-PublicFolderClientPermission -User $admin.DistinguishedName -AccessRights Owner -EA silentlycontinue