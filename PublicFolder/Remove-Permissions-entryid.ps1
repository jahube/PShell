$folderscope = '\'

$PFs = get-publicfolder $folderscope –Recurse -ResultSize unlimited ;
[System.Collections.ArrayList]$PFE = ($PFs).entryid ; $count = $PFE.count ;
for ($F = 0; $F -lt $PFE.count; $F++) { $ac = "Remove permission" ;
$Sts = "Remove permission: $([math]::Round($(($F/$count)*100))) %"; $Pc = (($F/$count)*100); $sc =$($count-$F)
Write-Progress -Activity $ac -Id 2 -ParentId 1 -Status $Sts -PercentComplete $Pc -SecondsRemaining = $sc
$PS = Get-PublicFolderClientPermission -identity $PFE[$F] ;
[System.Collections.ArrayList]$PM = @($PS.user.RecipientPrincipal.LegacyExchangeDN) ;
if ($PM) { foreach ($U in $PM) { Remove-PublicFolderClientPermission -Identity $PFE[$F] -User $U -CF:$false } }