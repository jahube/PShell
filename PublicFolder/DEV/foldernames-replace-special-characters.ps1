$folderscope = '\'
$empty = 0
$PFAll = get-publicfolder $folderscope –Recurse -ResultSize unlimited
$PFs = $PFAll.where({($_.Name -like "*\*") -or ($_.Name -like "*/*") -or ($_.Name -like "*;*") -or ($_.Name -like "*:*") -or ($_.Name -match ",") -or ($_.Name -match "^\s") -or ($_.Name -match "\s$")})
$total = $PFAll.count ; $count = $PFs.count ; $PFNew = @() ; $errs = @() ; 

#overview
Write-Host "Overall Invalid Folder Names [/\;:, ] - "-F yellow -NoNewLine ;
Write-Host "[$([math]::Round($(($count/$total)*100))) %] - Folder Count:  " $count -F yellow

$PFsSlash = $($PFs[$F].name).where({$_.Name -like "*/*"}) ; Write-Host "Slash [/] - "-F green -NoNewLine ;
Write-Host "[$([math]::Round($(($PFsSlash/$total)*100))) %] - Folder Count:  " $PFsSlash.count -F yellow

$PFsBackslash = $($PFs[$F].name).where({$_.Name -like "*\*"}) ; Write-Host "Backslash [\] - " -F green -NoNewLine ;
Write-Host "[$([math]::Round($(($PFsBackslash/$total)*100))) %] - Folder Count:  " $PFsBackslash.count -F yellow

$PFsSemicolon = $($PFs[$F].name).where({$_.Name -like "*;*"}) ; Write-Host "Semicolon [;] - " -F green -NoNewLine ;
Write-Host "[$([math]::Round($(($PFsSemicolon/$total)*100))) %] - Folder Count:  " $PFsSemicolon.count -F yellow

$PFsColon = $($PFs[$F].name).where({$_.Name -like "*:*"}) ; Write-Host "Colon [:] - " -F green -NoNewLine ;
Write-Host "[$([math]::Round($(($PFsColon/$total)*100))) %] - Folder Count:  " $PFsColon.count -F yellow

$PFsComma = $($PFs[$F].name).where({$_.Name -match ","}) ; Write-Host "Comma [,] - " -F green -NoNewLine ;
Write-Host "[$([math]::Round($(($PFsComma/$total)*100))) %] - Folder Count:  " $PFsComma.count -F yellow

$PFsStartWhitespace = $($PFs[$F].name).where({$_.Name -match "^\s"}) ; Write-Host "Starting Whitespace [ _] - " -F green -NoNewLine ;
Write-Host "[$([math]::Round($(($PFsStartWhitespace/$total)*100))) %] - Folder Count:  " $PFsStartWhitespace.count -F yellow

$PFsEndWhitespace = $($PFs[$F].name).where({$_.Name -match "\s$"}) ; Write-Host "Ending Whitespace [_ ] - " -F green -NoNewLine ;
Write-Host "[$([math]::Round($(($PFsEndWhitespace/$total)*100))) %] - Folder Count:  " $PFsEndWhitespace.count -F yellow

for ($F = 0; $F -lt $PFs.count; $F++) { 
Write-Progress -Activity "Replace characters" -Id 2 -ParentId 1 -Status "Replace characters: $([math]::Round($(($F/$count)*100))) %" -PercentComplete (($F/$count)*100) -SecondsRemaining $($count-$F)
$name = ($PFs[$F].name -replace ("\\|\/|\:|\;|\,","-").Trim()
Write-host "`nBefore: " $PFs[$F].name -F yellow ; Write-host "After: " $name -F green ; 
try{ Set-PublicFolder -Identity $PFs[$F].entryid -name $name -Confirm:$false  -EA 'stop' ; $PFNew += $name
} catch {  Write-host $Error[0].Exception.Message -F yellow $errs += $PFs[$F] } }   # end
Write-host "Successful " $PFNew.count -F green
Write-host "Failed " $errs.count -F yellow
$errs | Export-csv "C:\Failed_Folders.csv" -Notypeinformation