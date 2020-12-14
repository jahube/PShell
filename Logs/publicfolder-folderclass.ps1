$ts = Get-Date -Format yyyyMMdd_hhmmss ; $FormatEnumerationLimit = -1
$DesktopPath = ([Environment]::GetFolderPath('Desktop'))
$logsPATH = mkdir "$DesktopPath\MS-Logs\Public_Folder_LOGS_$ts"
Start-Transcript "$logsPATH\Public_Folder_LOGS_$ts.txt" -Verbose

$ITEMSSubfolder = "/Sub/Folder" # /Sub/Folder - ONLY use for a LIMITED subfolder for specific scenario

$PFStructure = Get-PublicFolder -Recurse -ResultSize Unlimited
$PFStructure | Get-PublicFolderItemStatistics | ?{$_.ItemType -eq "IPF.Contact"} | Export-CliXML $logsPATH\Contact-Folders.xml
$PFStructure | Get-PublicFolderItemStatistics | ?{$_.ItemType -eq "IPF.Note"} | Export-CliXML $logsPATH\Message-Folders.xml
$PFStructure | Export-CliXML $logsPATH\Legacy_PFStructure.xml
$PFStructure | Get-PublicFolderClientPermission | Select-Object Identity,User -ExpandProperty AccessRights | Export-CliXML $logsPATH\Legacy_PFPerms.xml
Get-Mailbox -PublicFolder | export-clixml $logsPATH\pfmbx.xml
Get-Mailbox -PublicFolder | Get-MailboxStatistics | export-clixml $logsPATH\pfmbxstat.xml
Get-Mailbox -PublicFolder | Get-PublicFolderMailboxDiagnostics -IncludeHierarchyInfo -IncludeDumpsterInfo -Debug –Verbose | export-clixml $logsPATH\pfmbxdiag.xml
Get-Mailbox -PublicFolder | select -expandproperty emailaddresses | FL > $logsPATH\MEPF-Aliases.txt
Get-Mailbox -PublicFolder | select -expandproperty emailaddresses | export-clixml $logsPATH\MEPF-Aliases.xml
Get-MailPublicFolder | select -expandproperty emailaddresses
Get-PublicFolderStatistics -ResultSize Unlimited | Export-CliXML $logsPATH\Legacy_PFStatistics.xml
Get-Recipient -RecipientTypeDetails PublicFolderMailbox | Export-clixml $logsPATH\Rec.xml
Get-Recipient -RecipientTypeDetails PublicFolderMailbox | Get-MailboxStatistics | Export-clixml $logsPATH\RecStat.xml
try { Get-Mailbox -PublicFolder -SoftDeletedMailbox | export-clixml $logsPATH\deleted-PFMBX.xml -EA stop } catch { write-host $Error[0] }
try { Get-Mailbox -PublicFolder -SoftDeletedMailbox | select -expandproperty emailaddresses | FL > $logsPATH\SoftDeleted-MEPF-Aliases.txt } catch { write-host $Error[0] } 
IF ($ITEMSSubfolder -ne "/Sub/Folder") { try { Get-PublicFolder $ITEMSSubfolder -Recurse | Get-PublicFolderItemStatistics | ?{$_.ItemType -eq "IPM.Contact"} | Export-CliXML $logsPATH\Contact-Items.xml -EA stop } catch { write-host $Error[0] } }
IF ($ITEMSSubfolder -ne "/Sub/Folder") { try { Get-PublicFolder $ITEMSSubfolder -Recurse | Get-PublicFolderItemStatistics | ?{$_.ItemType -eq "IPM.Note"} | Export-CliXML $logsPATH\Message-Items.xml -EA stop } catch { write-host $Error[0] } }
IF ($ITEMSSubfolder -ne "/Sub/Folder") { try { Get-PublicFolder $ITEMSSubfolder -Recurse | Get-PublicFolderItemStatistics | ?{$_.ItemType -eq "IPF.Contact"} | FT > $logsPATH\IPF.Contact.txt -EA stop } catch { write-host $Error[0] } }
IF ($ITEMSSubfolder -ne "/Sub/Folder") { try { Get-PublicFolder $ITEMSSubfolder -Recurse | Get-PublicFolderItemStatistics | ?{$_.ItemType -eq "IPF.Note"} | FT > $logsPATH\IPF.Note.txt -EA stop } catch { write-host $Error[0] } }

Stop-Transcript

$destination = "$DesktopPath\MS-Logs\Public_Folder_LOGS_$ts.zip"
Add-Type -assembly “system.io.compression.filesystem”
[io.compression.zipfile]::CreateFromDirectory($logsPATH, $destination) # ZIP
Invoke-Item $DesktopPath\MS-Logs # open file manager
#End
