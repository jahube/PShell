$FolterToDelete = "\Folder To Delete" # affected folder that cannot be deleted

# name for NEW test folder that will be created + deleted for testing purposes
$NewTestFolder = "MStestPFtemp"   

# EXO PS: connection commands reference
# install-module exchangeonlinemanagement
# connect-exchangeonline -userprincipalname "ADMIN@DOMAIN.com"

# desktop/MS-Logs+Timestamp
$ts = Get-Date -Format yyyyMMdd_hhmmss
$DesktopPath = ([Environment]::GetFolderPath('Desktop'))
$logsPATH = mkdir "$DesktopPath\MS-Logs\Public_Folder_Stats_$ts"

Start-Transcript "$logsPATH\Public_Folder_Stats_$ts.txt"
$FormatEnumerationLimit = -1

# Get the affected FOLDER and STATS - BEFORE
Get-publicfolder $FolterToDelete | FL >> "$LogsPath\FolterToDelete_Get_Publicfolder-BEFORE.txt"
$DelPFStats = Get-publicfolderstatistics $FolterToDelete
$DelPFStats | FL >> "$LogsPath\FolderToDelete_PublicfolderStatistics.txt"
$DelPFStats | Export-Clixml "$LogsPath\FolderToDelete_PublicfolderStatistics.xml"

# Run the command to REMOVE the unwanted PF
Remove-PublicFolder $FolterToDelete
$exception1 = $error[0].Exception ; $exception1 | fl *
$exception1 | fl * >> "$LogsPath\FolderToDelete_DeleteException.txt"

# Get the affected FOLDER            - AFTER
$DelPF = Get-publicfolder $FolterToDelete
$DelPF | fl * >> "$LogsPath\FolterToDelete_Get_Publicfolder-AFTER.txt"
$DelPF | Export-Clixml "$LogsPath\FolterToDelete_Get_Publicfolder-AFTER.xml"

#Get the affected DUMPSTER and STATS
$DelPF.dumpsterentryid | fl >> "$LogsPath\FolderToDelete_Dumpster_EntryID.txt"
$DelPFstats =  get-publicfolderstatistics -Identity $DelPF.dumpsterentryid
$error[0].Exception | fl * >> "$LogsPath\FolderToDelete_Dumpster_exception.txt"
$DelPFstats | fl * >> "$LogsPath\FolderToDelete_Dumpster_Stats.txt"
$DelPFstats | Export-Clixml "$LogsPath\FolderToDelete_Dumpster_Stats.xml"

# Create new test PF and see if you can remove it
New-PublicFolder -Name $NewTestFolder -Path \ -Confirm:$false
Get-PublicFolder "\$NewTestFolder" | fl * >> "$LogsPath\NewTestFolder_BEFORE.txt"
Remove-PublicFolder "\$NewTestFolder" -Confirm:$false
$exception2 = $error[0].Exception ; $exception2 | fl *
$exception2 | fl * >> "$LogsPath\NewTestFolder_DeleteException.txt"

  Try { Get-PublicFolder "\$NewTestFolder" -ErrorAction Stop | fl * >> "$LogsPath\NewTestFolder_AFTER.txt" }
Catch { $error[0].Exception | fl * >> "$LogsPath\NewTestFolder_AFTER-ExceptionOnly.txt" }

# general PF LOGS
$MEPF = Get-MailPublicFolder ; $MEPF | FL >> "$LogsPath\MEPF.txt"

Write-host "All PublicFolder Logs - this will take some time ... Thanks for your patience" -F green
$PFs = Get-PublicFolder \ -Recurse -resultsize unlimited
Write-host "All PublicFolder Logs - DONE" -F green
$PFs | select identity,Name,ParentPath,EntryId,DumpsterEntryId,ContentMailboxGuid | export-csv "$LogsPath\PF_ids.csv" -NoTypeInformation -Force
$PFs | Export-Clixml "$LogsPath\Get-PublicFolder-ALL.xml"

Write-host "All Dumpster Logs - this will also take some time ... Thanks for your patience" -F green
$Dumpster =  get-publicfolder "\NON_IPM_SUBTREE" -recurse -resultsize unlimited
Write-host "All Dumpster Logs - DONE - hang in - finished soon" -F green
$Dumpster | select identity,Name,ParentPath,EntryId,DumpsterEntryId,ContentMailboxGuid | export-csv "$LogsPath\NON_IPM_Dumpster_PublicFolder.csv" -NoTypeInformation -Force
$Dumpster | Export-Clixml "$LogsPath\NON_IPM_Dumpster_PublicFolder.xml"

$error[0].Exception | fl *

$PFMBX | Get-PublicFolderMailboxDiagnostics | Export-Clixml "$LogsPath\PublicFolderMailboxDiagnostics.xml"
$ORGPF = Get-OrganizationConfig ; $ORGPF | FL *publicfolder* >> "$LogsPath\OrganizationConfig.txt"
(Get-OrganizationConfig).RootPublicFolderMailbox.HierarchyMailboxGuid.GUID | FL >> "$LogsPath\HierarchyMailboxGuid.txt"

$PFMBX = Get-Mailbox -PublicFolder -ResultSize Unlimited
$PFMBX >> "$LogsPath\EXO_MailboxPublicFolder.txt"
$PFMBX | Export-Clixml "$LogsPath\EXO_MailboxPublicFolder.xml"
$PFMBX | Get-MailboxStatistics | Export-Clixml "$LogsPath\EXO_MailboxStatisticsPublicFolder.xml"
$PFMBXDiag = $PFMBX | Get-PublicFolderMailboxDiagnostics -IncludeHierarchyInfo -IncludeDumpsterInfo -Debug –Verbose 
$PFMBXDiag | Export-Clixml "$LogsPath\EXO_PublicFolderMailboxDiagnostics.xml"

Stop-Transcript
###### END TRANSCRIPT ######################
$destination = "$DesktopPath\MS-Logs\Public_Folder_Stats_$ts.zip"
Add-Type -assembly “system.io.compression.filesystem”
[io.compression.zipfile]::CreateFromDirectory($logsPATH, $destination) # ZIP
Invoke-Item $DesktopPath\MS-Logs # open file manager
###### END ZIP Logs ########################