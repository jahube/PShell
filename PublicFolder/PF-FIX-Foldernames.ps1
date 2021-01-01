$folderscope = '\'

$PFAll = get-publicfolder $folderscope –Recurse -ResultSize unlimited

$PFs = $PFAll.where({($_.Name -like "*\*") -or ($_.Name -like "*/*") -or ($_.Name -like "*;*") -or ($_.Name -like "*:*") -or ($_.Name -match ",") -or ($_.Name -match "^\s") -or ($_.Name -match "\s$")})
#$PFs = $PFAll.where({$_.Name -match [regex]::Escape('\'),[regex]::Escape('/'),[regex]::Escape(';'),[regex]::Escape(':'),[regex]::Escape(','),"^\s","\s$"})
#$PFs = $PFAll.where({$_.Name -match [regex]::Escape('\') -or $_.Name -match [regex]::Escape('/') -or $_.Name -match [regex]::Escape(';') -or $_.Name -match [regex]::Escape(':') -or $_.Name -match [regex]::Escape(',') -or ($_.Name -match "^\s") -or ($_.Name -match "\s$")})
$total = $PFAll.count ; $count = $PFs.count ; $PFNew = @() ; $errs = @() ; 

#overview
Write-Host "Overall Invalid Folder Names [/\;:, ] - "-F yellow -NoNewLine ;
Write-Host "[$([math]::Round($(($count/$total)*100))) %] - Folder Count:  " $count -F yellow
$PFsSlash = $PFs.where({$_.Name -match [regex]::Escape("/")})
IF($PFsSlash) {$Slash = $PFsSlash.count } else { $Slash = "0" }

Write-Host "Slash [/] - "-F green -NoNewLine ;
Write-Host "[$([math]::Round($(($Slash/$total)*100))) %] - Folder Count:  " $Slash -F yellow

$PFsBackslash = $PFs.where({$_.Name -match [regex]::Escape('\')})
IF($PFsBackslash) {$Backslash = $PFsBackslash.count } else { $Backslash = "0" }
Write-Host "Backslash [\] - " -F green -NoNewLine ;
Write-Host "[$([math]::Round($(($Backslash/$total)*100))) %] - Folder Count:  " $Backslash -F yellow

$PFsSemicolon = $PFs.where({$_.Name -match [regex]::Escape(';')}) ; 
IF($PFsSemicolon) {$Semicolon = $PFsSemicolon.count } else { $Semicolon = "0" }
Write-Host "Semicolon [;] - " -F green -NoNewLine ;
Write-Host "[$([math]::Round($(($Semicolon/$total)*100))) %] - Folder Count:  " $Semicolon -F yellow

$PFsColon = $PFs.where({$_.Name -match [regex]::Escape(':')})
IF($PFsColon) {$Colon = $PFsColon.count } else { $Colon = "0" }
Write-Host "Colon [:] - " -F green -NoNewLine ;
Write-Host "[$([math]::Round($(($Colon/$total)*100))) %] - Folder Count:  " $Colon -F yellow

$PFsComma = $PFs.where({$_.Name -match [regex]::Escape(',')})
IF($PFsComma) {$Comma = $PFsComma.count } else { $Comma = "0" }
 Write-Host "Comma [,] - " -F green -NoNewLine ;
Write-Host "[$([math]::Round($(($Comma/$total)*100))) %] - Folder Count:  " $Comma -F yellow

$PFsStartWhitespace = $PFs.where({$_.Name -match "^\s"}) ; 
IF($PFsStartWhitespace) {$StartWhitespace = $PFsStartWhitespace.count } else { $StartWhitespace = "0" }
Write-Host "Starting Whitespace [ _] - " -F green -NoNewLine ;
Write-Host "[$([math]::Round($(($StartWhitespace/$total)*100))) %] - Folder Count:  " $StartWhitespace -F yellow

$PFsEndWhitespace = $PFs.where({$_.Name -match "\s$"}) ; 
IF($PFsEndWhitespace) {$EndWhitespace = $PFsEndWhitespace.count } else { $EndWhitespace = "0" }
Write-Host "Ending Whitespace [_ ] - " -F green -NoNewLine ;
Write-Host "[$([math]::Round($(($EndWhitespace/$total)*100))) %] - Folder Count:  " $EndWhitespace -F yellow

for ($F = 0; $F -lt $PFs.count ; $F++) { 
Write-Progress -Activity "Replace characters" -Id 2 -ParentId 1 -Status "Replace characters: $([math]::Round($(($F/$count)*100))) %" -PercentComplete (($F/$count)*100) -SecondsRemaining $($count-$F)
$name = @($PFs[$F].name -replace "\\|\/|\:|\;|\,","-").Trim()
$name = $name -replace [regex]::Escape('/'),"-" -replace "^-" -replace "-$"
# $name.Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
Write-host "`nBefore: " $PFs[$F].name -F yellow ; Write-host "After: " $name -F green ;
try{ Set-PublicFolder -Identity $PFs[$F].entryid -name $name -Confirm:$false  -EA 'stop' ; $PFNew += $name
} catch {  Write-host $Error[0].Exception.Message -F yellow $errs += $PFs[$F] } }   # end

Write-host "Successful " $PFNew.count -F green
Write-host "Failed " $errs.count -F yellow
$errs | Export-csv "C:\Failed_Folders.csv" -Notypeinformation