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

#RELEASE
Release-QuarantineMessage –identity $Message.Identity -Confirm:$false -ReleaseToAll –Force # (release is commented out, remove ## to release ALL
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

