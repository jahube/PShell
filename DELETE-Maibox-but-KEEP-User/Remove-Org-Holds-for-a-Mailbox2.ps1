﻿Remove Org Holds for a Mailbox

################# connect#############

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Set-ExecutionPolicy RemoteSigned
Install-Module -Name ExchangeOnlineManagement

$ADMIN = "admin@domain.com"                # <-- modify admin

# Connect-ExchangeOnline -UserPrincipalName $ADMIN

Connect-IPPSSession -UserPrincipalName $ADMIN # security and compliance

#####################################

$user = "affected@user.com"              # <-- modify affected user

$policies = Get-RetentionCompliancePolicy

$policies | fl *guid*

######### Exo policy exclusion ##########

$EXO = $policies | where { $_.TeamsPolicy -eq $false } ; 

foreach ($EP in $EXO) {

                     Try { Set-RetentionCompliancePolicy -Identity $EP.Guid -AddExchangeLocationException $user -CF:$false -EA stop } 
                   catch { write-host $error[0]|fl*}
                     Try { Set-RetentionCompliancePolicy -identity $EP.Guid -RetryDistribution -CF:$false -EA stop } 
                    catch { write-host $error[0]|fl* }
         Get-RetentionCompliancePolicy -Identity $EP.Guid -DistributionDetail | FT Name,Type,ExchangeLocation*,DistributionStatus,Enabled,Mode
         Get-RetentionCompliancePolicy -Identity $EP.Guid -DistributionDetail | select -ExpandProperty ExchangeLocationException

                       }

################ end ####################

######### Teams policy exclusion #########
$teams = $policies | where { $_.TeamsPolicy -EQ $TRUE } ; 
foreach ($TP in $teams) {
                      Try { Set-TeamsRetentionCompliancePolicy -Identity $TP.Guid -AddTeamsChatLocationException $user  -CF:$false -EA stop } 
                    catch { write-host $error[0] | fl }
                      Try { Set-TeamsRetentionCompliancePolicy -identity $TP.Guid -RetryDistribution  -CF:$false -EA stop } 
                    catch { write-host $error[0] }
          Get-TeamsRetentionCompliancePolicy -Identity $TP.Guid -DistributionDetail | FT Name,Type,TeamsChatLocation*,DistributionStatus,Enabled,Mode
          Get-TeamsRetentionCompliancePolicy -Identity $TP.Guid -DistributionDetail | select -ExpandProperty TeamsChatLocationException 
                         }
################ end ####################

 
######### Hold policy exclusion #########

$Holds = Get-HoldCompliancePolicy ;

foreach ($H in $Holds) {

                       Try { Set-HoldCompliancePolicy -Identity $H.GUID -RemoveExchangeLocation $user -CF:$false -EA stop } 
                     catch { write-host $error[0] | fl }

                       Try { Set-HoldCompliancePolicy -Identity $H.GUID -RetryDistribution -CF:$false -EA stop } 
                     catch { write-host $error[0] }

                            Get-HoldCompliancePolicy -Identity $H.GUID -DistributionDetail | FT *location* 

                        }
################ end ####################

Get-ComplianceSearch 

######### Hold policy exclusion #########

$search = Get-ComplianceSearch #| where { $_.ExchangeLocation -match 'all'}

foreach ($S in $search) {

                       Try { Set-ComplianceSearch -Identity $S.Identity -RemoveExchangeLocation $user -CF:$false -EA stop } 
                     catch { write-host $error[0] | fl }

                       Try { Set-ComplianceSearch -Identity $S.Identity -AddExchangeLocationExclusion $user -CF:$false -EA stop } 
                     catch { write-host $error[0] | fl }

                             Get-ComplianceSearch -Identity $S.Identity | FT *location*
                        }

################ end ####################
