$HMBX = $(Get-OrganizationConfig).RootPublicFolderMailbox.HierarchyMailboxGuid ;

###########################################################################################################################################################
                              
                              $PFMSD = Get-Mailbox -PublicFolder -SoftDeletedMailbox ;
                                              Write-host @($PFMSD).count " SoftDeleted PF Mailboxes" -F Green

                              $SFTSF = $PFMSD | Where { $HMBX -ne $_.ExchangeGuid } ; $count =  @($SFTSF).count ;  $P = 0 

                          IF ($SFTSF) { Write-host @($SFTSF).count " SoftDeleted Secondary Hierarchy PF Mailboxes" -F Yellow

              foreach ($PF in $SFTSF) { $P++ ; $A = "Hard-Deleting Secondary PF Mailbox [ $P / $count ]" ;   $Prc = $(($P/$count)*100);
Write-Progress -Activity $A -Id 2 -ParentId 1 -Status " Mailbox [ $($PF.name) ] - time remaining: " -PercentComplete $Prc -SecondsRemaining (($count-$P)*3);
                                   try { Remove-Mailbox -PublicFolder -Identity $($PF.name) -PermanentlyDelete -Force -Confirm:$false -EA stop } 
                                 catch {  try { Remove-Mailbox -PublicFolder -Identity $($PF.Exchangeguid)[0] -PermanentlyDelete -Force -Confirm:$false -EA stop } 
                                        catch { Write-host $Error[0].exception.message -F Yellow } }                                
                                  }   } 

                    ELSEIF (!($SFTSF)){ Write-host "No SoftDeleted Secondary Hierarchy PF Mailboxes - SKIPPING" -F yellow }

###########################################################################################################################################################
                              $PFMSD = Get-Mailbox -PublicFolder ;
                 Write-host @($PFMSD).count " Active PF Mailboxes " -F Green

                              $SECPF = $PFMSD | Where { $HMBX -ne $_.ExchangeGuid } ; $count =  @($SECPF).count ;  $P = 0 

                          IF ($SECPF) { Write-host @($SECPF).count " Active Secondary Hierarchy PF Mailboxes" -F Yellow

              foreach ($PF in $SECPF) { $P++ ; $A = "Soft-Deleting Secondary Hierarchy PF Mailbox [ $P / $count ]" ;   $Prc = $(($P/$count)*100);
Write-Progress -Activity $A -Id 2 -ParentId 1 -Status " Mailbox [ $($PF.name) ] - time remaining: " -PercentComplete $Prc -SecondsRemaining (($count-$P)*3);
                                   try { Remove-Mailbox -PublicFolder -Identity $($PF.name) -Force -Confirm:$false -EA stop } 
                                 catch {  try { Remove-Mailbox -PublicFolder -Identity $($PF.Exchangeguid)[0] -PermanentlyDelete -Force -Confirm:$false -EA stop } 
                                        catch { Write-host $Error[0].exception.message -F Yellow } }                                
                                  }   } 

                    ELSEIF (!($SFTSPF)){ Write-host "No Active Secondary Hierarchy PF Mailboxes - SKIPPING" -F yellow }
                                          
###########################################################################################################################################################
                              
                              $PFMSD = Get-Mailbox -PublicFolder -SoftDeletedMailbox ;
                                              Write-host @($PFMSD).count " SoftDeleted PF Mailboxes" -F Green

                              $SFTSF = $PFMSD | Where { $HMBX -ne $_.ExchangeGuid } ; $count = @($SFTSF).count ;  $P = 0 

                          IF ($SFTSF) { Write-host @($SFTSF).count " SoftDeleted Secondary Hierarchy PF Mailboxes" -F Yellow

              foreach ($PF in $SFTSF) { $P++ ; $A = "Hard-Deleting Secondary Hierarchy PF Mailbox [ $P / $count ]" ;   $Prc = $(($P/$count)*100);
Write-Progress -Activity $A -Id 2 -ParentId 1 -Status " Mailbox [ $($PF.name) ] - time remaining: " -PercentComplete $Prc -SecondsRemaining (($count-$P)*3);
                                   try { Remove-Mailbox -PublicFolder -Identity $($PF.name) -PermanentlyDelete -Force -Confirm:$false -EA stop } 
                                 catch {  try { Remove-Mailbox -PublicFolder -Identity $($PF.Exchangeguid)[0] -PermanentlyDelete -Force -Confirm:$false -EA stop } 
                                        catch { Write-host $Error[0].exception.message -F Yellow } }                                
                                  }   } 

                    ELSEIF (!($SFTSF)){ Write-host "No SoftDeleted Secondary Hierarchy PF Mailboxes - SKIPPING" -F yellow }

###########################################################################################################################################################
###########################################################################################################################################################

                              $PFMBX = Get-Mailbox -PublicFolder 
                              $PFMSD = Get-Mailbox -PublicFolder -SoftDeletedMailbox ;
                              $SECPF = $PFMBX | Where { $HMBX -ne $_.ExchangeGuid }
                              $SFTSF = $PFMSD | Where { $HMBX -ne $_.ExchangeGuid }
                              $PRIPF = $PFMBX | Where { $HMBX -eq $_.ExchangeGuid } ; $count = @($PRIPF).count ;  $P = 0 
                              $SFTPF = $PFMSD | Where { $HMBX -eq $_.ExchangeGuid }

                              IF ($SECPF) { Write-host @($SECPF).count " Active PF Mailboxes`n Missing Step 2 >> SOFT-Delete Secondary Hierarchy Mailboxes" -F yellow }
                              IF ($SFTSF) { Write-host @($SFTSF).count " Softdeleted  SECONDARY PF Mailboxes `n Missing Step 3 >> Hard-Delete Secondary Hierarchy Mailboxes" -F yellow }
                          ElSEIF ($PRIPF) { Write-host @($PRIPF).count " Active Primary PF Mailboxes `n Continue Step 4 + 5 / SOFT + Hard-Delete Primary Hierarchy Mailbox" -F yellow }
                          ElSEIF ($SFTPF) { Write-host @($SFTPF).count " Softdeleted Primary PF Mailboxes `n Continue Step 5 Hard-Delete Primary Hierarchy Mailbox" -F yellow }
                                     ElSE { Write-host $(@($PFMBX).count + @($PFMSD).count) " PF Mailboxes" -F Green }
                              IF ($PRIPF) {
              foreach ($PF in $PRIPF) { $P++ ; $A = "Soft-Deleting Active Primary Hierarchy PF Mailbox [ $P / $count ]" ;   $Prc = $(($P/$count)*100);
Write-Progress -Activity $A -Id 2 -ParentId 1 -Status " Mailbox [ $($PF.name) ] - time remaining: " -PercentComplete $Prc -SecondsRemaining (($count-$P)*3);
                                   try { Remove-Mailbox -PublicFolder -Identity $($PF.name) -Force -Confirm:$false -EA stop } 
                                 catch {  try { Remove-Mailbox -PublicFolder -Identity $($PF.Exchangeguid.Guid)[0] -Force -Confirm:$false -EA stop } 
                                        catch { Write-host $Error[0].exception.message -F Yellow } }                                
                                      }   } 
                       ELSEIF (!($SFTSPF)){ Write-host "No Active Primary Hierarchy PF Mailboxes - SKIPPING" -F yellow }
                                          
###########################################################################################################################################################

                              $PFMBX = Get-Mailbox -PublicFolder
                              $PFMSD = Get-Mailbox -PublicFolder -SoftDeletedMailbox ;
                              $SECPF = $PFMBX | Where { $HMBX -ne $_.ExchangeGuid }
                              $SFTSF = $PFMSD | Where { $HMBX -ne $_.ExchangeGuid }
                              $PRIPF = $PFMBX | Where { $HMBX -eq $_.ExchangeGuid }  
                              $SFTPF = $PFMSD | Where { $HMBX -eq $_.ExchangeGuid }  ; $count = @($SFTPF).count ;  $P = 0

                              IF ($SECPF) { Write-host @($SECPF).count " Active PF Mailboxes`n Missing Step 2 >> SOFT-Delete Secondary Hierarchy Mailboxes" -F yellow }
                              IF ($SFTSF) { Write-host @($SFTSF).count " Softdeleted  SECONDARY PF Mailboxes `n Missing Step 3 >> Hard-Delete Secondary Hierarchy Mailboxes" -F yellow }
                          ElSEIF ($PRIPF) { Write-host @($PRIPF).count " Active Primary PF Mailboxes `n Continue Step 4 + 5 / SOFT + Hard-Delete Primary Hierarchy Mailbox" -F yellow }
                          ElSEIF ($SFTPF) { Write-host @($SFTPF).count " Softdeleted Primary PF Mailboxes `n Continue Step 5 Hard-Delete Primary Hierarchy Mailbox" -F yellow }
                                     ElSE { Write-host $(@($PFMBX).count + @($PFMSD).count) " PF Mailboxes" -F Green }
                              IF ($SFTPF) {
              foreach ($PF in $SFTPF) { $P++ ; $A = "HARD-Deleting Active Primary Hierarchy PF Mailbox [ $P / $count ]" ;   $Prc = $(($P/$count)*100);
Write-Progress -Activity $A -Id 2 -ParentId 1 -Status " Mailbox [ $($PF.name) ] - time remaining: " -PercentComplete $Prc -SecondsRemaining (($count-$P)*3);
                                   try { Remove-Mailbox -PublicFolder -Identity $($PF.name) -PermanentlyDelete -Force -Confirm:$false -EA stop } 
                                 catch { sleep 5 ; $SFTPF = Get-Mailbox -PublicFolder -SoftDeletedMailbox | Where { $HMBX -eq $_.ExchangeGuid } ;
                                             try { $SFTPF | % { Remove-Mailbox -PublicFolder -Identity $($_.Exchangeguid.guid) -PermanentlyDelete -Force -Confirm:$false -EA stop } }
                                           catch { Write-host $Error[0].exception.message -F Yellow ;
                                                   $SFTPF | Remove-Mailbox -PublicFolder -PermanentlyDelete -Force -Confirm:$false -EA silentlycontinue  
                                                   Write-host "Attempting alternative Hard-deletion" -F yellow  } }                                
                                      }   } 
                       ELSEIF (!($SFTPF)){ Write-host "No SoftDeleted Primary Hierarchy PF Mailboxes - SKIPPING" -F yellow }
