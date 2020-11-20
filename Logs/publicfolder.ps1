$ts = Get-Date -Format yyyyMMdd_hhmmss ; $FormatEnumerationLimit = -1
$DesktopPath = ([Environment]::GetFolderPath('Desktop'))
$logsPATH =mkdir "$DesktopPath\MS-Logs\$ts"
Start-Transcript "$logsPATH\PublicFolder$ts.txt" -Verbose

Get-Mailbox -PublicFolder | export-clixml $logsPATH\pfmbx.xml
Get-Mailbox -PublicFolder | Get-MailboxStatistics | export-clixml $logsPATH\pfmbxstat.xml
Get-Mailbox -PublicFolder | Get-PublicFolderMailboxDiagnostics -IncludeHierarchyInfo -IncludeDumpsterInfo -Debug –Verbose | export-clixml $logsPATH\pfmbxdiag.xml
Get-PublicFolder -Recurse -ResultSize Unlimited | Export-CliXML $logsPATH\Legacy_PFStructure.xml
Get-PublicFolderStatistics -ResultSize Unlimited | Export-CliXML $logsPATH\Legacy_PFStatistics.xml
Get-PublicFolder -Recurse -ResultSize Unlimited | Get-PublicFolderClientPermission | Select-Object Identity,User -ExpandProperty AccessRights | Export-CliXML $logsPATH\Legacy_PFPerms.xm
Get-Mailbox -PublicFolder -SoftDeletedMailbox | export-clixml $logsPATH\delpfmbx.xml
Get-Recipient -RecipientTypeDetails PublicFolderMailbox | Export-clixml $logsPATH\Rec.xml
Get-Recipient -RecipientTypeDetails PublicFolderMailbox | Get-MailboxStatistics | Export-clixml $logsPATH\RecStat.xml
Get-MailPublicFolder | select -expandproperty emailaddresses
Get-Mailbox -PublicFolder -SoftDeletedMailbox | select -expandproperty emailaddresses

Stop-Transcript

$destination = "$DesktopPath\MS-Logs\Logs_$ts.zip"
Add-Type -assembly “system.io.compression.filesystem”
[io.compression.zipfile]::CreateFromDirectory($logsPATH, $destination) # ZIP
Invoke-Item $DesktopPath\MS-Logs # open file manager