$HMBX = $(Get-OrganizationConfig).RootPublicFolderMailbox.HierarchyMailboxGuid ;

###########################################################################################################################################################                              
                              $PFMSD = Get-Mailbox -PublicFolder -SoftDeletedMailbox | select -Property ExchangeGuid ; 
                                              Write-host $PFMSD.count " SoftDeleted PF Mailboxes" -F Green
                              $SFTPF = $PFMSD | Where { $HMBX -ne $_.ExchangeGuid } ; $count = $SFTPF.count
                          IF ($SFTPF) { Write-host $SFTPF.count " SoftDeleted Secondary Hierarchy PF Mailboxes" -F Yellow
[System.Collections.ArrayList]$SFT = @($SFTPF.Exchangeguid)
          for ($P = 0; $P -lt $SFT.count; $P++) {         $A = "Hard-Deleting Secondary PF Mailbox [ $P / $count ]" ;    $Prc = $(($P/$count)*100);
Write-Progress -Activity $A -Id 2 -ParentId 1 -Status $($($SFT[$P]).guid) -PercentComplete $Prc -SecondsRemaining (($count-$P)*3);
                                   try { Remove-Mailbox -PublicFolder -Identity $($SFT[$P]).guid -PermanentlyDelete -Force -Confirm:$false -EA stop } 
                                 catch { Write-host $Error[0].exception.message -F Yellow } } } 
                    ELSEIF (!($SFTSPF)){ Write-host "No SoftDeleted Secondary Hierarchy PF Mailboxes - SKIPPING" -F yellow }

###########################################################################################################################################################
                              
                              $PFMBX = Get-Mailbox -PublicFolder | select -Property ExchangeGuid ; 
                                             Write-host $PFMBX.count " Active PF Mailboxes" -F Green
                              $SECPF = $PFMBX | Where { $HMBX -ne $_.ExchangeGuid } ; $count = $SECPF.count
                          IF ($SECPF) { Write-host $SECPF.count " Active Secondary Hierarchy PF Mailboxes" -F Green
[System.Collections.ArrayList]$SEC = @($SECPF.Exchangeguid)
          for ($P = 0; $P -lt $SEC.count; $P++) {         $A = "Soft-Deleting Active Secondary PF Mailbox [ $P / $count ]" ;    $Prc = $(($P/$count)*100);
Write-Progress -Activity $A -Id 2 -ParentId 1 -Status $($($SEC[$P]).guid) -PercentComplete $Prc -SecondsRemaining (($count-$P)*3);
                                   try { Remove-Mailbox -PublicFolder -Identity $($SEC[$P]).guid -Force -Confirm:$false -EA stop } 
                                 catch { Write-host $Error[0].exception.message -F Yellow } } } 
                    ELSEIF (!($SECPF)) { Write-host "No Active Secondary Hierarchy PF Mailboxes - SKIPPING" -F yellow }
                                          
###########################################################################################################################################################

                              $PFMSD = Get-Mailbox -PublicFolder -SoftDeletedMailbox | select -Property ExchangeGuid ; 
                                             Write-host $PFMSD.count " SoftDeleted PF Mailboxes" -F Green
                              $SFTSPF = $PFMSD | Where { $HMBX -ne $_.ExchangeGuid } ; $count = $SFTPF.count
                          IF ($SFTSPF) { Write-host $SFTSPF.count " SoftDeleted Secondary Hierarchy PF Mailboxes" -F Yellow
[System.Collections.ArrayList]$SFT = @($SFTSPF.Exchangeguid)
          for ($P = 0; $P -lt $SFT.count; $P++) {         $A = "Hard-Deleting Secondary PF Mailbox [ $P / $count ]" ;    $Prc = $(($P/$count)*100);
Write-Progress -Activity $A -Id 2 -ParentId 1 -Status $($($SFT[$P]).guid) -PercentComplete $Prc -SecondsRemaining (($count-$P)*3);
                                   try { Remove-Mailbox -PublicFolder -Identity $($SFT[$P]).guid -PermanentlyDelete -Force -Confirm:$false -EA stop } 
                                 catch { Write-host $Error[0].exception.message -F Yellow } } } 
                    ELSEIF (!($SFTSPF)){ Write-host "No SoftDeleted Secondary Hierarchy PF Mailboxes - SKIPPING" -F yellow }

###########################################################################################################################################################
###########################################################################################################################################################

                              $PFMBX = Get-Mailbox -PublicFolder | select -Property ExchangeGuid ; 
                                             Write-host $PFMBX.count " Active PF Mailboxes" -F Green
                              $PRIPF = $PFMBX | Where { $HMBX -eq $_.ExchangeGuid } ; $count = $PRIPF.count
                          IF ($PRIPF) { Write-host $PRIPF.count " Active Primary Hierarchy PF Mailboxes" -F Green
[System.Collections.ArrayList]$PRI = @($PRIPF.Exchangeguid)
          for ($P = 0; $P -lt $PRI.count; $P++) {         $A = "Soft-Deleting Primary Hierarchy PF Mailbox " ;    $Prc = $(($P/$count)*100);
Write-Progress -Activity $A -Id 2 -ParentId 1 -Status $($($PRI[$P]).guid) -PercentComplete $Prc -SecondsRemaining (($count-$P)*3);
                                   try { Remove-Mailbox -PublicFolder -Identity $($PRI[$P]).guid -Force -Confirm:$false -EA stop } 
                                 catch { Write-host $Error[0].exception.message -F Yellow } } } 
                    ELSEIF (!($PRIPF)) { Write-host "No Active Primary Hierarchy PF Mailboxes - SKIPPING" -F yellow }
                                          
###########################################################################################################################################################

                              $PFMSD = Get-Mailbox -PublicFolder -SoftDeletedMailbox | select -Property ExchangeGuid ; 
                                             Write-host $PFMSD.count " SoftDeleted PF Mailboxes" -F Green
                              $SFTPPF = $PFMSD | Where { $HMBX -eq $_.ExchangeGuid } ; $count = $SFTPPF.count
                          IF ($SFTPPF) { Write-host $SFTPPF.count " SoftDeleted Primary Hierarchy PF Mailboxes" -F Yellow
[System.Collections.ArrayList]$SFT = @($SFTPPF.Exchangeguid)
          for ($P = 0; $P -lt $SFT.count; $P++) {         $A = "Hard-Deleting Primary Hierarchy PF Mailbox " ;    $Prc = $(($P/$count)*100);
Write-Progress -Activity $A -Id 2 -ParentId 1 -Status $($($SFT[$P]).guid) -PercentComplete $Prc -SecondsRemaining (($count-$P)*3);
                                   try { Remove-Mailbox -PublicFolder -Identity $($SFT[$P]).guid -PermanentlyDelete -Force -Confirm:$false -EA stop } 
                                 catch { Write-host $Error[0].exception.message -F Yellow } } } 
                    ELSEIF (!($SFTPPF)) { Write-host "No SoftDeleted Primary Hierarchy PF Mailboxes - SKIPPING" -F yellow }