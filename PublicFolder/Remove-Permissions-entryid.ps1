$folderscope = '\'
$empty = 0
$PFs = get-publicfolder $folderscope –Recurse -ResultSize unlimited
[System.Collections.ArrayList]$PFE = ($PFs).entryid
$count = $PFE.count
for ($F = 0; $F -lt $PFE.count; $F++) { 
Write-Progress -Activity "Remove permission" -Id 2 -ParentId 1 -Status "Remove permission: $([math]::Round($(($F/$count)*100))) %" -PercentComplete (($F/$count)*100) -SecondsRemaining $($count-$F)
$PS = Get-PublicFolderClientPermission -identity $PFE[$F]
[System.Collections.ArrayList]$PM = @($PS.user.RecipientPrincipal.LegacyExchangeDN)
if ($PM) { 
foreach ($U in $PM) { 
#try{ 
Remove-PublicFolderClientPermission -Identity $PFE[$F] -User $U -Confirm:$false
# -EA 'stop' } catch {  Write-host $Error[0].Exception.Message -F yellow }
 } } else { $empty++ } } # end