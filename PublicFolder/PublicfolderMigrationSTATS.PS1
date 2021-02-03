#EXO PS:
# install-module exchangeonlinemanagement
# connect-exchangeonline -userprincipalname "ADMIN@DOMAIN.com"

# desktop/MS-Logs+Timestamp
$ts = Get-Date -Format yyyyMMdd_hhmmss
$DesktopPath = ([Environment]::GetFolderPath('Desktop'))
$logsPATH =mkdir "$DesktopPath\MS-Logs\Public_Folder_Migration_Stats_$ts"

Start-Transcript "$logsPATH\Public_Folder_Migration_Stats_$ts.txt"
$FormatEnumerationLimit = -1

$Param = @{ IncludeReport = $true
           DiagnosticInfo = "showtimeline,showtimeslots,verbose" }
$PFMigbatch = Get-MigrationBatch @Param | ?{$_.MigrationType.ToString() -eq "PublicFolder"}
$PFMigbatch | export-clixml $logsPATH\EXO_PFMigbatch.xml

$PFMiguser = get-migrationuser -batchid "PublicfolderMigration"
# $PFMiguser = $PFMigbatch | get-migrationuser

$PFMiguser | Export-CliXML $logsPATH\EXO_PFMiguser.xml
$PFMiguserStats = $PFMiguser | Get-MigrationUserStatistics @Param
$PFMiguserStats | Export-CliXML "$logsPATH\EXO_PFmbxmigUserStats.xml"

$PFMigReq = Get-PublicFolderMailboxMigrationRequest
$PFMigReqStats = $PFMigReq | Get-PublicFolderMailboxMigrationRequestStatistics @Param
$PFMigReqStats | Export-CliXML $logsPATH\EXO_PFMigReq.xml

# large items: 
$largeitems = ForEach ($i in $PFMigReqStats) {if ($i.LargeItemsEncountered -gt 0) {$i.TargetMailbox.Name,$i.report.largeitems.messagesize}}
$largeitems | Export-CliXML $logsPATH\EXO_PFMig_largeitems.xml

# bad items: 
$baditems = ForEach ($i in $PFMigReqStats) {if ($i.BadItemsEncountered -gt 0) {$i.TargetMailbox.Name,$i.report.baditems.subject}}
$baditems | Export-CliXML $logsPATH\EXO_PFMig_baditems.xml

Stop-Transcript
###### END TRANSCRIPT ######################
$destination = "$DesktopPath\MS-Logs\Public_Folder_Migration_Stats_$ts.zip"
Add-Type -assembly “system.io.compression.filesystem”
[io.compression.zipfile]::CreateFromDirectory($logsPATH, $destination) # ZIP
Invoke-Item $DesktopPath\MS-Logs # open file manager
###### END ZIP Logs ########################


