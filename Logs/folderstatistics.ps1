$ts = Get-Date -Format yyyyMMdd_hhmmss ; $FormatEnumerationLimit = -1
$DesktopPath = ([Environment]::GetFolderPath('Desktop'))
$logsPATH =mkdir "$DesktopPath\MS-Logs\$ts"
Start-Transcript "$logsPATH\Folderstatistics$ts.txt" -Verbose

$mbx = "affected user"

get-mailboxfolderstatistics $mbx | export-clixml $logsPATH\EXO_IPM_MbxFStats.xml
get-mailboxfolderstatistics $mbx -FolderScope nonIPMroot | export-clixml $logsPATH\EXO_NONIPM_MbxFStats.xml
get-mailboxfolderstatistics $mbx -FolderScope all | export-clixml $logsPATH\EXO_all_MbxFStats.xml
get-mailboxfolderstatistics $mbx | ft folderpath,containerclass,foldertype,itemsinfolder,itemsinfolderandsubfolders
get-mailboxfolderstatistics $mbx | ft folderpath,containerclass,foldertype,itemsinfolder,itemsinfolderandsubfolders > $logsPATH\list.txt
get-mailboxfolderstatistics $mbx -FolderScope nonIPMroot | ft folderpath, itemsinfolder, itemsinfolderandsubfolders
get-mailboxfolderstatistics $mbx -FolderScope all | ft folderpath, itemsinfolder, itemsinfolderandsubfolders
Get-MailboxFolderstatistics $mbx | Select-Object *,@{ Name = "SizeInBytes"; Expression={ [Uint64]::Parse([Regex]::Match($_.FolderSize.ToString(), '\(([0-9,]+) bytes\)').Groups[1].Value.Replace(",","")) } } | Sort SizeInBytes -Descending | ft FolderPath,FolderSize,itemsinfolder
Get-MailboxFolderstatistics $mbx -FolderScope nonIPMroot | Select-Object *,@{ Name = "SizeInBytes"; Expression={ [Uint64]::Parse([Regex]::Match($_.FolderSize.ToString(), '\(([0-9,]+) bytes\)').Groups[1].Value.Replace(",","")) } } | Sort SizeInBytes -Descending | ft FolderPath,FolderSize,itemsinfolder
Get-MailboxFolderstatistics $mbx -FolderScope all | Select-Object *,@{ Name = "SizeInBytes"; Expression={ [Uint64]::Parse([Regex]::Match($_.FolderSize.ToString(), '\(([0-9,]+) bytes\)').Groups[1].Value.Replace(",","")) } } | Sort SizeInBytes -Descending | ft FolderPath,FolderSize,itemsinfolder

Stop-Transcript

$destination = "$DesktopPath\MS-Logs\Logs_$ts.zip"
Add-Type -assembly “system.io.compression.filesystem”
[io.compression.zipfile]::CreateFromDirectory($logsPATH, $destination) # ZIP
Invoke-Item $DesktopPath\MS-Logs # open file manager