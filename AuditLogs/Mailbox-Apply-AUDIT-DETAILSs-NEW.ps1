      start-transcript -verbose

$user = "AFFECTED@USER.com"  # modify USER only + connect Powershell / Exchange Online 

          # check results BEFORE

$MBX = Get-Mailbox $user ; $PROW1 = $MBX.AuditOwner ; $PRDL1 = $MBX.AuditDelegate
 Write-host "BEFORE: AuditOwner = $($PROW1.count)" -foregroundcolor yellow;  Write-host "AuditOwner: $($PROW1)" -foregroundcolor Cyan
 Write-host "BEFORE: AuditOwner = $($PRDL1.count)" -foregroundcolor yellow;  Write-host "AuditOwner: $($PRDL1)" -foregroundcolor Cyan

        $All = 'Create', 'HardDelete', 'MoveToDeletedItems', 'RecordDelete', 'RemoveFolderPermissions','SoftDelete', 'Update', 'UpdateFolderPermissions', 'UpdateInboxRules'
$OwnANDdelgt =  'AddFolderPermissions', 'ApplyRecord', 'ModifyFolderPermissions','Move','UpdateCalendarDelegation'
      $Owner = 'Send', 'MailboxLogin'
   $Delegate = 'FolderBind', 'SendAs', 'SendOnBehalf'
      $Admin = 'Copy', 'SendAs', 'SendOnBehalf', 'UpdateCalendarDelegation'

            # Apply ALL DETAILS

$Parameter = @{ identity = $user ;  
            AuditEnabled = $true ;
              AuditOwner = $All + $OwnANDdelgt + $Owner
           AuditDelegate = $All + $OwnANDdelgt + $Delegate
              AuditAdmin = $All + $Admin }
                Set-Mailbox @Parameter 

         # On /Off to refresh update

set-MailboxAuditBypassAssociation -Identity $user -AuditBypassEnabled $true  #OFF
set-MailboxAuditBypassAssociation -Identity $user -AuditBypassEnabled $false  #ON

           # recheck results AFTER

$MBX = Get-Mailbox $user ; $PROW1 = $MBX.AuditOwner ; $PRDL1 = $MBX.AuditDelegate
 Write-host "AFTER: AuditOwner = $($PROW.count)" -foregroundcolor yellow;  Write-host "AuditOwner: $($PROW)" -foregroundcolor Cyan
 Write-host "AFTER: AuditOwner = $($PRDL.count)" -foregroundcolor yellow;  Write-host "AuditOwner: $($PRDL)" -foregroundcolor Cyan

          # enable Unified Audit logs

IF(!((Get-AdminAuditLogConfig).UnifiedAuditLogIngestionEnabled)) {
Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $true ;
Write-host "Unified Audit log was disabled - ENABLING NOW" -F yellow }

stop-transcript

#End