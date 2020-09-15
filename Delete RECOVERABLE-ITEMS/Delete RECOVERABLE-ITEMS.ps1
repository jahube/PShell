# Source https://docs.microsoft.com/en-gb/microsoft-365/compliance/delete-items-in-the-recoverable-items-folder-of-mailboxes-on-hold?view=o365-worldwide

# modify only the affected user
$user = "email@affected-user.com"

# list HOLDS
Get-Mailbox $user | FL LitigationHoldEnabled,InPlaceHolds

 # switch MAILBOX ACCESS OFF
Set-CASMailbox $user -EwsEnabled $false -ActiveSyncEnabled $false -MAPIEnabled $false -OWAEnabled $false -ImapEnabled $false -PopEnabled $false

 # set Dumpster Retention policy
Set-Mailbox $user -RetainDeletedItemsFor 30

# single items recovery OFF
Set-Mailbox $user -SingleItemRecoveryEnabled $false

# prevent the Managed Folder Assistant from processing the mailbox
Set-Mailbox $user -ElcProcessingDisabled $true

# After this Command we should wait One Hour for Repplication Time
 # litigation hold OFF
Set-Mailbox $user -LitigationHoldEnabled $false
 # 3 types of delay holds
Set-Mailbox $user –RetentionHoldEnabled $false
Set-Mailbox $user –RemoveDelayHoldApplied
Set-Mailbox $user –RemoveDelayReleaseHoldApplied

# DELETE DUMPSTER + Backup
Get-Mailbox $user -resultsize unlimited | Search-mailbox -SearchDumpsterOnly -TargetMailbox "Discovery Search Mailbox" -TargetFolder "$user" -DeleteContent -Force

 # DELETE DUMPSTER + no backup
Search-Mailbox $user -SearchQuery size>8200000 -SearchDumpsterOnly –DeleteContent

Search-Mailbox $user -SearchDumpsterOnly -DeleteContent

Get-Mailbox $user -resultsize unlimited | Search-mailbox -SearchDumpsterOnly -DeleteContent -Force

$getMBX = Get-Mailbox $user -resultsize unlimited

# get RESULT
Get-MailboxFolderStatistics $user -FolderScope RecoverableItems | FL Name,FolderAndSubfolderSize,ItemsInFolderAndSubfolders

 # switch MAILBOX ACCESS ON
Set-CASMailbox $user -EwsEnabled $true -ActiveSyncEnabled $true -MAPIEnabled $true -OWAEnabled $true -ImapEnabled $true -PopEnabled $true


# restore settings

# single items recovery ON
Set-Mailbox $user -SingleItemRecoveryEnabled $true


# alternative to just apply changed retention policies by MRM process which otherwise takes up tp 7 days

# Start-ManagedFolderAssistant -Identity $user
 # get RESULT
Get-Mailbox $user | FL ElcProcessingDisabled,InPlaceHolds,LitigationHoldEnabled,RetainDeletedItemsFor,SingleItemRecoveryEnabled
•	remove Org Holds [ example link ]

