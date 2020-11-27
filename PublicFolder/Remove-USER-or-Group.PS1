$folderscope = '\'

#GROUP
$Group = 'group name' 
$access = (Get-DistributionGroup $Group).Distinguishedname ;

#USER
$access = 'user to remove' #MODIFY

$empty = 0
$PFs = get-publicfolder $folderscope –Recurse -ResultSize unlimited

[System.Collections.ArrayList]$PFE = ($PFs).entryid
$count = $PFE.count
for ($F = 0; $F -lt $PFE.count; $F++) { 
Write-Progress -Activity "Remove permission" -Id 2 -ParentId 1 -Status "Remove permission: $([math]::Round($(($F/$count)*100))) %" -PercentComplete (($F/$count)*100) -SecondsRemaining $($count-$F)
# Remove-PublicFolderClientPermission -Identity $PFE[$F] -User $access -Confirm:$false
try { Remove-PublicFolderClientPermission -Identity $PFE[$F] -User $access -Confirm:$false -EA 'stop' } catch {  Write-host $Error[0].Exception.Message -F yellow }
} # end

#$Group = 'pfsec' 
#$access = (Get-DistributionGroup $Group).Distinguishedname ;
# Remove-DistributionGroup pfsec $access