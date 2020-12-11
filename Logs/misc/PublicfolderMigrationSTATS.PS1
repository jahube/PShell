#EXO PS:
# install-module exchangeonlinemanagement
# connect-exchangeonline -userprincipalname "ADMIN@DOMAIN.com"

# desktop/MS-Logs+Timestamp
$ts = Get-Date -Format yyyyMMdd_hhmmss
$DesktopPath = ([Environment]::GetFolderPath('Desktop'))
$logsPATH =mkdir "$DesktopPath\MS-Logs\Public_Folder_Migration_Stats_$ts"

Start-Transcript "$logsPATH\Public_Folder_Migration_Stats_$ts"
$FormatEnumerationLimit = -1

$PFMs = get-mailbox -publicfolder | FT Displayname,userprincipalname,primarySMTPaddress
ForEach ($PFM in $PFMs.userprincipalname) { $upath = $($logsPATH + '\' + "$PFM" + '_EXO_PFmbxmigUserStats.xml')
Get-MigrationUserStatistics $PFM -DiagnosticInfo Verbose -IncludeReport | Export-CliXML "$upath" }
Get-PublicFolderMailboxMigrationRequest | Get-PublicFolderMailboxMigrationRequestStatistics -IncludeReport -DiagnosticInfo Verbose | Export-CliXML $logsPATH\EXO_PFMigReq.xml
Get-MigrationBatch -DiagnosticInfo Verbose -IncludeReport | ?{$_.MigrationType.ToString() -eq "PublicFolder"} | export-clixml $logsPATH\EXO_PFMigbatch.xml
# large items: 
$pf=Get-PublicFolderMailboxMigrationRequest | Get-PublicFolderMailboxMigrationRequestStatistics -IncludeReport;
$largeitems = ForEach ($i in $pf) {if ($i.LargeItemsEncountered -gt 0) {$i.TargetMailbox.Name,$i.report.largeitems.messagesize}}
$largeitems | Export-CliXML $logsPATH\EXO_PFMig_largeitems.xml
# bad items: 
$pf=Get-PublicFolderMailboxMigrationRequest | Get-PublicFolderMailboxMigrationRequestStatistics -IncludeReport; 
$baditems = ForEach ($i in $pf) {if ($i.BadItemsEncountered -gt 0) {$i.TargetMailbox.Name,$i.report.baditems.subject}}
$baditems | Export-CliXML $logsPATH\EXO_PFMig_baditems.xml

Stop-Transcript
###### END TRANSCRIPT ######################
$destination = "$DesktopPath\MS-Logs\Public_Folder_Migration_Stats_$ts.zip"
Add-Type -assembly “system.io.compression.filesystem”
[io.compression.zipfile]::CreateFromDirectory($logsPATH, $destination) # ZIP
Invoke-Item $DesktopPath\MS-Logs # open file manager
###### END ZIP Logs ########################


