start-transcript -verbose

$user = ""  # modify AFFECTED@USER.com

# desktop/MS-Logs+Timestamp

$ts = Get-Date -Format yyyyMMdd_hhmmss
$DesktopPath = ([Environment]::GetFolderPath('Desktop'))
$logsPATH = mkdir "$DesktopPath\MS-Logs\Mailbox-Audit-Logs_$ts"

Start-Transcript "$logsPATH\Transcript_$ts.txt"
$FormatEnumerationLimit = -1

# check PS Session + check Exo Module V2 (+ install if not found) + connect + $credentials

IF(!@(Get-PSSession | where { $_.State -ne "broken" } )) {
IF(!@(Get-InstalledModule ExchangeOnlineManagement -ErrorAction SilentlyContinue)) { install-module exchangeonlinemanagement -Scope CurrentUser }

IF(!@($Credentials)) {$Credentials = Get-credential } ; IF(!@($ADMIN)) {$ADMIN = $Credentials.UserName }
Try { Connect-ExchangeOnline -Credential $Credentials -EA stop } catch { Connect-ExchangeOnline -UserPrincipalName $ADMIN } }

IF (!($Credentials.UserName -in (get-RoleGroupMember "Organization Management").primarySMTPaddress)) { Add-RoleGroupMember "Organization Management" -Member $ADMIN
Try { Connect-ExchangeOnline -Credential $Credentials -EA stop } catch { Connect-ExchangeOnline -UserPrincipalName $ADMIN } }

Try {$All = Get-ExoMailbox -ResultSize unlimited -Properties Name,PrimarySMTPaddress,Displayname,Userprincipalname,Guid,DistinguishedName,alias -EA stop } catch { $All = get-mailbox -ResultSize unlimited }
 IF ($All.Count -gt "400") { $Data = Read-Host -Prompt "Affected User [Userprincipalname]" }                      # Above threshold - ask for manual user input
                      ELSE { $Data = @($All | select PrimarySMTPaddress,Displayname,Userprincipalname,alias,name | Out-GridView -Passthru -Title "Select User").userprincipalname } # below threshold

# enable Unified Audit logs
IF(!((Get-AdminAuditLogConfig).UnifiedAuditLogIngestionEnabled)) {
Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $true ;
Write-host "Unified Audit log was disabled - ENABLING NOW" -F yellow }

Foreach ($U in $Data) {
 Try { $M = Get-ExoMailbox $U -Properties Name,PrimarySMTPaddress,Displayname,Userprincipalname,Guid,DistinguishedName -PropertySets Audit -EA stop } catch { $M = get-mailbox $U }

 Write-host "BEFORE: $(@($M.AuditOwner).count) [Owner]" -F Yellow -n  ; Write-host "- Audited Operations: `n $($M.AuditOwner)`n" -F Green
 Write-host "BEFORE: $(@($M.AuditDelegate).count) [Delegate]" -F Yellow -n  ; Write-host "- Audited Operations: `n $($M.AuditDelegate)`n" -F cyan
 Write-host "BEFORE: $(@($M.AuditAdmin).count) [Admin]" -F Yellow -n  ; Write-host "- Audited Operations: `n $($M.AuditAdmin)`n" -F White

$Param = @{ AuditOwner = 'AddFolderPermissions', 'ApplyRecord', 'Create', 'Send', 'HardDelete', 'MailboxLogin', 'ModifyFolderPermissions', 'Move', 'MoveToDeletedItems', 'RecordDelete', 'RemoveFolderPermissions', 'SoftDelete', 'Update', 'UpdateFolderPermissions', 'UpdateCalendarDelegation', 'UpdateInboxRules' ;
         AuditDelegate = 'AddFolderPermissions', 'ApplyRecord', 'Create', 'FolderBind', 'HardDelete', 'ModifyFolderPermissions', 'Move', 'MoveToDeletedItems', 'RecordDelete', 'RemoveFolderPermissions', 'SendAs', 'SendOnBehalf', 'SoftDelete', 'Update', 'UpdateFolderPermissions', 'UpdateInboxRules' ;
            AuditAdmin = 'Copy', 'Create', 'HardDelete', 'MoveToDeletedItems', 'RecordDelete', 'RemoveFolderPermissions', 'SendAs', 'SendOnBehalf', 'SoftDelete', 'Update', 'UpdateFolderPermissions', 'UpdateCalendarDelegation', 'UpdateInboxRules' }
           Set-Mailbox -identity $M.UserPrincipalName -AuditEnabled $true @Param ;  
         
                    # Set-Mailbox -Identity $M.UserPrincipalname -AuditEnabled $false        #OFF
                    # Set-Mailbox -Identity $M.UserPrincipalname -AuditEnabled $true         #ON = update refresh Unified Audit
set-MailboxAuditBypassAssociation -Identity $M.UserPrincipalname -AuditBypassEnabled $true   #OFF
set-MailboxAuditBypassAssociation -Identity $M.UserPrincipalname -AuditBypassEnabled $false  #ON = update refresh Mbx Audit
   
   Write-host $M.DisplayName ' ⋆⋅☆⋅⋆ Settings Applied  ⋆⋅☆⋅⋆ ' -F yellow -B DarkBlue
 Try { $M = Get-ExoMailbox $U -Properties Name,PrimarySMTPaddress,Displayname,Userprincipalname,Guid,DistinguishedName -PropertySets Audit -EA stop } catch { $M = get-mailbox $U }
 $M | fl *audit*
 Write-host "AFTER: $(@($M.AuditOwner).count) [Owner]" -F Yellow -n  ; Write-host "- Audited Operations: `n $($M.AuditOwner)`n" -F Green
 Write-host "AFTER: $(@($M.AuditDelegate).count) [Delegate]" -F Yellow -n  ; Write-host "- Audited Operations: `n $($M.AuditDelegate)`n" -F cyan
 Write-host "AFTER: $(@($M.AuditAdmin).count) [Admin]" -F Yellow -n  ; Write-host "- Audited Operations: `n $($M.AuditAdmin)`n" -F White

 } # End Foreach per User

stop-transcript