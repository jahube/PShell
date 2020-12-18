Start-transcript

##############################################################################################

$CalReviewer = "default"  # $CalReviewer = "admin@domain.com" OR security group
$REVaccess = 'Reviewer' # to change back use 'LimitedDetails'

$CalEditor = "admin@domain.com"   ;
$EDaccess = 'Editor' ; 

# $REMOVEEditor = 'YES'

$types = "Contacts","Calendar"

##############################################################################################

$MBX = Get-recipient -Resultsize Unlimited | where {$_.RecipientTypeDetails -match "RoomMailbox"}
foreach ($M in $MBX) {
Write-Host -ForegroundColor green "collecting permissions for $($M.alias)..."
$stats = Get-MailboxFolderStatistics $M.alias
$stats | ft CreationTime,LastModifiedTime,Name,FolderPath,foldertype,containerclass
$stats | ? { $_.identity -match 'BookingStaff'} | ft CreationTime,LastModifiedTime,Name,FolderPath,foldertype,containerclass
$stats | ? { $_.identity -match 'calendar'}  | ft CreationTime,LastModifiedTime,Name,FolderPath,foldertype,containerclass
$stats | ? { $_.containerclass -eq 'IPF.Appointment'}  | ft CreationTime,LastModifiedTime,Name,FolderPath,foldertype,containerclass
$stats | ? { $_.identity -match 'contacts'}  | ft CreationTime,LastModifiedTime,Name,FolderPath,foldertype,containerclass
Get-MailboxCalendarFolder "$($user.alias):\calendar" |ft
$D = $M.distinguishedname ; $A = $M.alias ; $U = $M.PrimarySmtpAddress.ToString()
foreach($F in (Get-MailboxFolderStatistics $A | ? {$_.foldertype.tostring() -in ($types)})){ 
$FN = $A + ':' + $F.FolderPath.Replace('/','\'); write-host "BEFORE" -F Cyan ; 
Try { Get-MailboxFolderPermission $FN -EA stop | ft } catch { write-host $Error[0].Exception.message -F yellow }

# ADD Reviever
write-host "`n[REVIEWER] $CalReviewer `n" -F cyan ; 
Try { Add-MailboxFolderPermission $FN -User $CalReviewer -AccessRights $REVaccess -EA stop ; 
write-host "`nADD [REVIEWER] $CalEDITOR Successful" -F green } catch { write-host $Error[0].Exception.message -F yellow ;
 
# Skip for Default / Anonymous
IF (($CalReviewer -ne "default") -and ($CalReviewer -ne "anonymous")) {write-host $Error[0].Exception.message -F yellow ; 
write-host "`nREMOVE [REVIEWER] $CalReviewer" -F yellow ; 
Try { Remove-MailboxFolderPermission $FN -User $CalReviewer -EA stop -Confirm:$false ; 
write-host "`nADD [REVIEWER] $CalReviewer second try" -F cyan ; } catch { write-host $Error[0].Exception.message -F yellow }
Try {    Add-MailboxFolderPermission $FN -User $CalReviewer -AccessRights $REVaccess -EA stop ; 
write-host "`nADD [REVIEWER] $CalReviewer Successful RESET" -F green 
} catch { write-host $Error[0].Exception.message -F yellow } } }

# ADD
IF($REMOVEEditor -ne 'YES') { write-host "`n`n[EDITOR] $CalEDITOR `n" -F cyan ; 
Try { Add-MailboxFolderPermission $FN -User $CalEDITOR -AccessRights $EDaccess -EA stop ;
write-host "`nADD [EDITOR] $CalEDITOR Successful" -F green } catch { 
write-host $Error[0].Exception.message -F yellow ; write-host "`nREMOVE [EDITOR] $CalEDITOR" -F yellow ; 
Try { Remove-MailboxFolderPermission $FN -User $CalEDITOR -EA stop -Confirm:$false ; 
write-host "`nADD [EDITOR] $CalEDITOR second try" -F cyan ;      } catch { write-host $Error[0].Exception.message -F yellow }
Try {    Add-MailboxFolderPermission $FN -User $CalEDITOR -AccessRights $EDaccess -EA stop ; 
write-host "`nADD [EDITOR] $CalEDITOR Successful RESET" -F green } catch { write-host $Error[0].Exception.message -F yellow } } }

# Remove on $REMOVEEditor = "YES"
IF($REMOVEEditor -eq 'YES') { write-host "REMOVE [EDITOR] $CalEDITOR" -F yellow ; 
Try { Remove-MailboxFolderPermission $FN -User $CalEDITOR -EA stop -Confirm:$false ; 
write-host "`nREMOVE [EDITOR] $CalEDITOR Successful" -F green ; } catch { write-host $Error[0].Exception.message -F yellow } }
write-host "`n`n AFTER" -F green ; Try { Get-MailboxFolderPermission $FN -EA stop | ft 
} catch { write-host $Error[0].Exception.message -F yellow }  }  }

stop-transcript