#EXO PS:
# install-module exchangeonlinemanagement
# connect-exchangeonline -userprincipalname "ADMIN@DOMAIN.com"

get-mailbox -publicfolder | FT Displayname,userprincipalname,primarySMTPaddress
 
$path = "C:\temp"
$PFMBX = "<address of cloud public folder mailbox>"
 
Get-MigrationUserStatistics $PFMBX -DiagnosticInfo Verbose -IncludeReport | Export-CliXML $path\EXO_PFmbxmigUserStats.xml

Get-PublicFolderMailboxMigrationRequest | Get-PublicFolderMailboxMigrationRequestStatistics -IncludeReport -DiagnosticInfo Verbose | Export-CliXML $path\EXO_PFMigReq.xml

Get-MigrationBatch -DiagnosticInfo Verbose -IncludeReport | ?{$_.MigrationType.ToString() -eq "PublicFolder"} | export-clixml $path\EXO_PFMigbatch.xml

# large items: 
$pf=Get-PublicFolderMailboxMigrationRequest | Get-PublicFolderMailboxMigrationRequestStatistics -IncludeReport;
ForEach ($i in $pf) {if ($i.LargeItemsEncountered -gt 0) {$i.TargetMailbox.Name,$i.report.largeitems.messagesize}}

# bad items: 
$pf=Get-PublicFolderMailboxMigrationRequest | Get-PublicFolderMailboxMigrationRequestStatistics -IncludeReport; 
ForEach ($i in $pf) {if ($i.BadItemsEncountered -gt 0) {$i.TargetMailbox.Name,$i.report.baditems.subject}}

#Follow these steps, if you are ok with skipping the large/bad items: 
#Approve the skipped items on Migration batch: 
Set-MigrationBatch <batchname> -ApproveSkippedItems 
	
#Use following command to approve the skipped items on migration requests that are “Synced” but not completed: 
$pf=Get-PublicFolderMailboxMigrationRequest | Get-PublicFolderMailboxMigrationRequestStatistics -IncludeReport; 
ForEach ($i in $pf) {if ($i.LargeItemsEncountered -gt 0 -or $i.BadItemsEncountered -gt 0) {
Set-PublicFolderMailboxMigrationRequest $i.Identity.IdentifyingGuid -SkippedItemApprovalTime $([DateTime]::UtcNow)}} 

# The migration batch and requests should resume and Complete