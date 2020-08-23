$ts = Get-Date -Format yyyyMMdd_hhmmss
$FormatEnumerationLimit = -1
$DesktopPath = ([Environment]::GetFolderPath('Desktop'))
$logsPATH = mkdir "$DesktopPath\MS-Logs\$ts\MS-Logs_Headers"
$MailPATH = mkdir "$DesktopPath\MS-Logs\$ts\QuarantineMessages”
Start-Transcript -Path $logsPATH\LOGS$ts.txt
$MessageSearch = Get-QuarantineMessage
$MessageSearch | Select-Object ReceivedTime,SenderAddress,RecipientAddress,QuarantineTypes,PolicyType,PolicyName,Reported,ReleaseStatus,Expires,MessageId | `
Export-Csv -Path "$logsPATH\1_Before-MessageSearch_$ts.csv" -NoTypeInformation
$mcount = 1
$Messagecount = $MessageSearch.count
Foreach ($Message in $MessageSearch) {
$m = $null
$m = Export-QuarantineMessage -Identity $Message.Identity

$MessageId = $null
$MessageId = $Message.MessageId -Replace "(\<)|(\>)", ""
$MessageId = $MessageId -Replace "(\@)", "_"
$filePath = "$MailPATH" + “\$MessageId" + ".eml”
if([System.IO.File]::Exists($filePath) -eq $true) {$filePath = $filePath + "_" + (Get-Date -Format mmss)}

Write-Progress -Activity "Exporting to Desktop - MS-Logs - current Message-ID" -Id 2 -ParentId 1 -Status "Message: $($MessageId)" -PercentComplete (($mcount/$Messagecount)*100)

# 7bit / ascii
If (($m.BodyEncoding -ne 'Base64') -or ($m.BodyEncoding -notmatch 'binary')) { $m.Eml | Out-File -FilePath "$filePath" -Encoding ascii }

#base64
If ($m.BodyEncoding -eq 'Base64') {
$mdec = [System.Text.Encoding]::Utf8.GetString([Convert]::FromBase64String($($m.Eml)))
$mdec | Out-File -FilePath "$filePath" -Encoding ascii 
}

#binary
If ($m.BodyEncoding -match 'binary') {[IO.File]::WriteAllBytes("$filePath", $mdec)}

$header = Get-QuarantineMessageHeader –identity $Message.Identity
$headerpath = “$logsPATH\$MessageId.txt”
if([System.IO.File]::Exists($headerpath) -eq $true) {$headerpath=("$logsPATH\$MessageId" + "_" + (Get-Date -Format mmss) + ".txt")}
$header.Header | Out-File -FilePath $headerpath -Encoding UTF8
## Release-QuarantineMessage –identity $Message.Identity -Confirm:$false -ReleaseToAll –Force # (release is commented out, remove ## to release ALL
$mcount++
}
$MessageSearch2 = Get-QuarantineMessage
$MessageSearch2 | Select-Object ReceivedTime,SenderAddress,RecipientAddress,QuarantineTypes,PolicyType,PolicyName,Reported,ReleaseStatus,Expires,MessageId,ReleasedUser,QuarantinedUser | `
Export-Csv -Path "$logsPATH\2_After-MessageSearch_$ts.csv" -NoTypeInformation
Stop-Transcript
$destination = "$DesktopPath\MS-Logs\$ts" + "\MS-Logs_Headers_$ts.zip"
Add-Type -assembly “system.io.compression.filesystem”
[io.compression.zipfile]::CreateFromDirectory($logsPATH, $destination)
Invoke-Item "$DesktopPath\MS-Logs\$ts"

