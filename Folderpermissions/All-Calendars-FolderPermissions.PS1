Start-transcript

##############################################################################################
# REVIEWER
$CalReviewer = "default"                 # $CalReviewer = "admin@domain.com" OR security group
$REVaccess = 'LimitedDetails'            # 'LimitedDetails' or 'Reviewer'
##############################################################################################
# EDITOR
$CalEditor = "admin@domain.com"
$EDaccess = 'Reviewer'                   # 'Editor' or 'LimitedDetails' or 'Reviewer'
##############################################################################################
# $REMOVEEditor = 'YES'
##############################################################################################
# $CalEditor = @(get-mailbox $CalEditor).primarysmtpaddress
# $CalEditor = @(get-mailbox $CalEditor).distinguishedname

$MBX = get-recipient -Resultsize Unlimited
foreach ($M in $MBX) {
Write-Host -ForegroundColor green "adding permissions for $($M.alias)..."

$types = "Calendar"
$D = $M.distinguishedname ; $A = $M.alias ; $U = $M.PrimarySmtpAddress.ToString()
foreach($F in (get-MailboxFolderStatistics $A | ? {$_.foldertype.tostring() -in ($types)})){ 
$FN = $A + ':' + $F.FolderPath.Replace('/','\'); write-host "BEFORE" -F Cyan ; 
Try { get-MailboxFolderPermission $FN -EA stop | ft } catch { write-host $Error[0].Exception.message -F yellow }
# ADD Reviever
write-host "`n[REVIEWER] $CalReviewer `n" -F cyan ; 
Try { Add-MailboxFolderPermission $FN -User $CalReviewer -AccessRights $REVaccess -EA stop ; 
write-host "`nADD [REVIEWER] $CalEDITOR Successful" -F green } catch { write-host $Error[0].Exception.message -F yellow ;
 
# Skip for Default / Anonymous
IF (($CalReviewer -ne "default") -and ($CalReviewer -ne "anonymous")) {write-host $Error[0].Exception.message -F yellow ; 
write-host "`nREMOVE [REVIEWER] $CalReviewer" -F yellow ; 
Try { remove-MailboxFolderPermission $FN -User $CalReviewer -EA stop -Confirm:$false ; 
write-host "`nADD [REVIEWER] $CalReviewer second try" -F cyan ; } catch { write-host $Error[0].Exception.message -F yellow }
Try {    Add-MailboxFolderPermission $FN -User $CalReviewer -AccessRights $REVaccess -EA stop ; 
write-host "`nADD [REVIEWER] $CalReviewer Successful RESET" -F green 
} catch { write-host $Error[0].Exception.message -F yellow } } }
# ADD
IF($REMOVEEditor -ne 'YES') { write-host "`n`n[EDITOR] $CalEDITOR `n" -F cyan ; 
Try { Add-MailboxFolderPermission $FN -User $CalEDITOR -AccessRights $EDaccess -EA stop ;
write-host "`nADD [EDITOR] $CalEDITOR Successful" -F green } catch { 
write-host $Error[0].Exception.message -F yellow ; write-host "`nREMOVE [EDITOR] $CalEDITOR" -F yellow ; 
Try { remove-MailboxFolderPermission $FN -User $CalEDITOR -EA stop -Confirm:$false ; 
write-host "`nADD [EDITOR] $CalEDITOR second try" -F cyan ;      } catch { write-host $Error[0].Exception.message -F yellow }
Try {    Add-MailboxFolderPermission $FN -User $CalEDITOR -AccessRights $EDaccess -EA stop ; 
write-host "`nADD [EDITOR] $CalEDITOR Successful RESET" -F green } catch { write-host $Error[0].Exception.message -F yellow } } }
# Remove on $REMOVEEditor = "YES"
IF($REMOVEEditor -eq 'YES') { write-host "REMOVE [EDITOR] $CalEDITOR" -F yellow ; 
Try { remove-MailboxFolderPermission $FN -User $CalEDITOR -EA stop -Confirm:$false ; 
write-host "`nREMOVE [EDITOR] $CalEDITOR Successful" -F green ; } catch { write-host $Error[0].Exception.message -F yellow } }
write-host "`n`n AFTER" -F green ; Try { get-MailboxFolderPermission $FN -EA stop | ft 
} catch { write-host $Error[0].Exception.message -F yellow }  }  }
stop-transcript
