start-transcript -verbose

$user = "AFFECTED@USER.com"  # please modify

# check results BEFORE
$PROW1 = Get-Mailbox $user | select -expandproperty AuditOwner
 Write-host "BEFORE: AuditOwner = $($PROW1.count)" -foregroundcolor yellow;  Write-host "AuditOwner: $($PROW1)" -foregroundcolor Cyan
$PRDL1 =Get-Mailbox $user | select -expandproperty AuditDelegate
 Write-host "BEFORE: AuditOwner = $($PRDL1.count)" -foregroundcolor yellow;  Write-host "AuditOwner: $($PRDL1)" -foregroundcolor Cyan
 
# Apply ALL DETAILS
$Parameter = @{ identity = $user ; AuditEnabled = $true ;
AuditOwner = 'AddFolderPermissions', 'ApplyRecord', 'Create', 'Send', 'HardDelete', 'MailboxLogin', 'ModifyFolderPermissions', 'Move', 'MoveToDeletedItems', 'RecordDelete', 'RemoveFolderPermissions', 'SoftDelete', 'Update', 'UpdateFolderPermissions', 'UpdateCalendarDelegation', 'UpdateInboxRules' ;
AuditDelegate = 'AddFolderPermissions', 'ApplyRecord', 'Create', 'FolderBind', 'HardDelete', 'ModifyFolderPermissions', 'Move', 'MoveToDeletedItems', 'RecordDelete', 'RemoveFolderPermissions', 'SendAs', 'SendOnBehalf', 'SoftDelete', 'Update', 'UpdateFolderPermissions', 'UpdateInboxRules' ;
AuditAdmin = 'Copy', 'Create', 'HardDelete', 'MoveToDeletedItems', 'RecordDelete', 'RemoveFolderPermissions', 'SendAs', 'SendOnBehalf', 'SoftDelete', 'Update', 'UpdateFolderPermissions', 'UpdateCalendarDelegation', 'UpdateInboxRules' }
Set-Mailbox @Parameter 

# On /Off to refresh update
set-MailboxAuditBypassAssociation -Identity $user -AuditBypassEnabled $true  #OFF
set-MailboxAuditBypassAssociation -Identity $user -AuditBypassEnabled $false  #ON

# recheck results AFTER
$PROW = Get-Mailbox $user | select -expandproperty AuditOwner
 Write-host "AFTER: AuditOwner = $($PROW.count)" -foregroundcolor yellow;  Write-host "AuditOwner: $($PROW)" -foregroundcolor Cyan
$PRDL =Get-Mailbox $user | select -expandproperty AuditDelegate
 Write-host "AFTER: AuditOwner = $($PRDL.count)" -foregroundcolor yellow;  Write-host "AuditOwner: $($PRDL)" -foregroundcolor Cyan

# enable Unified Audit logs
IF(!((Get-AdminAuditLogConfig).UnifiedAuditLogIngestionEnabled)) {
Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $true ;
Write-host "Unified Audit log was disabled - ENABLING NOW" -F yellow }

stop-transcript