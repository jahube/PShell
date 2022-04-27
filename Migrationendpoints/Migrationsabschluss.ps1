# Filter  Batches
$batches = Get-MigrationBatch | where { $_.identity -match "ludwigsburg"}                     # Batches Filtern
$batches

# (1) Approve + Complete Batches
$batches | % { Set-MigrationBatch $_.batchguid -ApproveSkippedItems }                         # APPROVE BATCH
$batches | % { Set-MigrationBatch $_.batchguid -CompleteAfter (get-date).ToUniversalTime() }  # COMPLETE Now

# Filter  Migrationusers
$MigrationUser = $batches | % { Get-MigrationUser -BatchId $_.batchguid }                     # MigrationsUSER der Batches
$NeedsApprova l = $MigrationUser | ? { $_.status -eq "NeedsApproval" }                        # MigrationsUSER nach Status filtern

# (2) Approve + ReSync +  Complete
$NeedsApproval | % { set-MigrationUser $_.guid -ApproveSkippedItems }                         # APPROVE USER mit Status "Investigate"
$NeedsApproval | % { set-MigrationUser $_.guid -SyncNow }                                     # SYNC     Now
$NeedsApproval | % { set-MigrationUser $_.guid -CompleteAfter (get-date).ToUniversalTime() }  # COMPLETE Now

# (3) STOP ("Pause") + Approve + START ("Resume") + ReSync +  Complete
$NeedsApproval | % { stop-MigrationUser $_.guid }                                             # STOP ("Anhalten")
$NeedsApproval | % { set-MigrationUser $_.guid -ApproveSkippedItems }                         # APPROVE USER
$NeedsApproval | % { start-MigrationUser $_.guid }                                            # START ("Fortsetzen")
$NeedsApproval | % { set-MigrationUser $_.guid -SyncNow }                                     # SYNC     Now
$NeedsApproval | % { set-MigrationUser $_.guid -CompleteAfter (get-date).ToUniversalTime() }  # COMPLETE Now

# (4) STOP ("Pause") + Approve + START ("Resume") + ReSync +  Complete
$NeedsApproval | % { stop-MigrationUser $_.guid }                                             # STOP ("Anhalten")
$NeedsApproval | % { Suspend-MoveRequest $_.MailboxEmailAddress  }                            # Suspend-MoveReques
$NeedsApproval | % { set-MigrationUser $_.guid -ApproveSkippedItems }                         # APPROVE USER
$NeedsApproval | % { set-MigrationUser $_.guid -BadItemLimit 150 -LargeItemLimit 100 }        # BadItemLimit + LargeItemLimit
$NeedsApproval | % { Set-MailUser $_.MailboxEmailAddress -MaxReceiveSize 150MB }              # MailUser MaxReceiveSize
$NeedsApproval | % { start-MigrationUser $_.guid }                                            # START ("Fortsetzen")
$NeedsApproval | % { Resume-MoveRequest $_.MailboxEmailAddress -MaxReceiveSize 150MB }        # Resume-MoveRequest
$NeedsApproval | % { set-MigrationUser $_.guid -SyncNow }                                     # SYNC     Now
$NeedsApproval | % { set-MigrationUser $_.guid -ApproveSkippedItems }                         # APPROVE USER
$NeedsApproval | % { set-MigrationUser $_.guid -CompleteAfter (get-date).ToUniversalTime() }  # COMPLETE Now

# (5) FIX Source Side / Indexing + MaxReceiveSize 150MB (Transportconfig / Mailuser)

# Referenz: https://www.frankysweb.de/exchange-20132016-index-neu-erstellen/

# DAG: Update-MailboxDatabaseCopy
# Referenzen: 
# https://docs.microsoft.com/de-de/exchange/high-availability/manage-ha/update-db-copies
# https://www.frankysweb.de/exchange-20132016-index-neu-erstellen/
# https://www.stellarinfo.com/article/reseed-a-failed-database-copy-in-exchange-server.php
# https://www.nucleustechnologies.com/blog/update-mailboxdatabasecopy-failed-and-suspended/

<#
# Restart Indexing Service onprem

Stop-Service MSExchangeFastSearch
Stop-Service HostControllerService

# Open a file browser (Admin) and navigate to Exchange mailbox directory.
# C:\Program Files\Microsoft\Exchange Server\V15\Mailbox\Mailbox Database 123
# move the Index 12854239C-1823-8c32-ODJQ-SSDFK123CSDFG.1.Single to new subfolder/backup

Start-Service MSExchangeFastSearch
Start-Service HostControllerService

# Rebuild Content Indexing
# Suspend-MoveRequest / Resume-MoveRequest 
# stop-MigrationUser  / start-MigrationUser
# Stop-MigrationBatch / Resume-MigrationBatch
#>

# (6) Fix DC + Migrationsendpunkt + MigEndpunkt Credentials in Cloud + Connectivity / Authentication / load balancer (no ssl offloading) etc