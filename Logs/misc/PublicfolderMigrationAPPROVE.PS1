#Follow these steps, if you are ok with skipping the large/bad items: 

#Approve the skipped items on Migration batch: 

Set-MigrationBatch <batchname> -ApproveSkippedItems 
	
#Use following command to approve the skipped items on migration requests that are “Synced” but not completed: 

$pf=Get-PublicFolderMailboxMigrationRequest | Get-PublicFolderMailboxMigrationRequestStatistics -IncludeReport; 
ForEach ($i in $pf) {if ($i.LargeItemsEncountered -gt 0 -or $i.BadItemsEncountered -gt 0) {
Set-PublicFolderMailboxMigrationRequest $i.Identity.IdentifyingGuid -SkippedItemApprovalTime $([DateTime]::UtcNow)}} 

# The migration batch and requests should resume and Complete