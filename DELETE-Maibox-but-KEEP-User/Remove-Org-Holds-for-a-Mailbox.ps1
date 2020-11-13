Remove Org Holds for a Mailbox

################# connect#############
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Set-ExecutionPolicy RemoteSigned
Install-Module -Name ExchangeOnlineManagement

#modify Admin
$admin = "admin2@edu.dnsabr.com"   
                  
Connect-ExchangeOnline -UserPrincipalName $admin -ShowProgress $true #modify Admin please
 
# SCC / security and compliance
Connect-IPPSSession -UserPrincipalName $admin

#####################################

# modify affected user
$user = "affected@user.com" 

$policies = Get-RetentionCompliancePolicy
$policies | fl *guid*
 

######### Exo policy exclusion ##########
$EXO = $policies | where { $_.TeamsPolicy -eq $false } 
foreach ($EP in $EXO) {
Try { Set-RetentionCompliancePolicy -Identity $EP.Guid -AddExchangeLocationException $user -confirm:$false } catch { write-host $error[0] | fl }
Try { Set-RetentionCompliancePolicy -identity $EP.Guid -RetryDistribution -confirm:$false } catch { write-host $error[0] }
Get-RetentionCompliancePolicy -Identity $EP.Guid -DistributionDetail | FT Name,Type,ExchangeLocation,ExchangeLocationException,DistributionStatus,Enabled,Mode
Get-RetentionCompliancePolicy -Identity $EP.Guid -DistributionDetail | select -ExpandProperty ExchangeLocationException
}
################ end ####################
 


######### Teams policy exclusion #########
$teams = $policies | where { $_.TeamsPolicy -EQ $TRUE }
foreach ($TP in $teams) {
Try { Set-TeamsRetentionCompliancePolicy -Identity $TP.Guid -AddTeamsChatLocationException $user -confirm:$false } catch { write-host $error[0] | fl }
Try { Set-TeamsRetentionCompliancePolicy -identity $TP.Guid -RetryDistribution -confirm:$false } catch { write-host $error[0] }
Get-TeamsRetentionCompliancePolicy -Identity $TP.Guid -DistributionDetail | FT Name,Type,TeamsChatLocation,TeamsChatLocationException,DistributionStatus,Enabled,Mode
Get-TeamsRetentionCompliancePolicy -Identity $TP.Guid -DistributionDetail | select -ExpandProperty TeamsChatLocationException
}
################ end ####################
 


######### Hold policy exclusion #########
$Holds = Get-HoldCompliancePolicy
foreach ($H in $Holds) {
Try { Set-HoldCompliancePolicy -Identity $H.GUID -RemoveExchangeLocation $user -confirm:$false } catch { write-host $error[0] | fl }
Try { Set-HoldCompliancePolicy -Identity $H.GUID -RetryDistribution -confirm:$false } catch { write-host $error[0] }
Get-HoldCompliancePolicy -Identity $H.GUID -DistributionDetail | FT *location*
}
################ end ####################

Get-ComplianceSearch 


######### Hold policy exclusion #########
$search = Get-ComplianceSearch #| where { $_.ExchangeLocation -match 'all'}
foreach ($S in $search) {
Try { Set-ComplianceSearch -Identity $S.Identity -RemoveExchangeLocation $user -CF:$false -EA stop } catch { write-host $error[0] | fl }
Try { Set-ComplianceSearch -Identity $S.Identity -AddExchangeLocationExclusion $user -CF:$false -EA stop } catch { write-host $error[0] | fl }
Try { Set-ComplianceSearch -Identity $S.Identity -RetryDistribution -confirm:$false } catch { write-host $error[0] }
Get-ComplianceSearch -Identity $S.Identity | FT *location*
}
################ end ####################
