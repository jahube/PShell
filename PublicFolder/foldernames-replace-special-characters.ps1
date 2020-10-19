$folderscope = '\'
$empty = 0
$PFs = get-publicfolder $folderscope –Recurse -ResultSize unlimited
$PFs =  $PFs | where { ($_.Name -like "*\*") -or ($_.Name -like "*/*") -or ($_.Name -like "*;*")-or ($_.Name -like "*:*")-or ($_.Name -match ",")}
$PFNew = @() ; $errs = @()
$count = $PFs.count
for ($F = 0; $F -lt $PFs.count; $F++) { 
Write-Progress -Activity "Replace characters" -Id 2 -ParentId 1 -Status "Replace characters: $([math]::Round($(($F/$count)*100))) %" -PercentComplete (($F/$count)*100) -SecondsRemaining $($count-$F)
$name = $PFs[$F].name -replace ("\\|\/|\:|\;|\,","-")
try{ Set-PublicFolder -Identity $PFs[$F].entryid -name $name -Confirm:$false  -EA 'stop' ; $PFNew += $name
} catch {  Write-host $Error[0].Exception.Message -F yellow $errs += $PFs[$F] } }   # end