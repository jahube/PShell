
################# connect#############
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Set-ExecutionPolicy RemoteSigned
Install-Module -Name ExchangeOnlineManagement

#modify Admin
$admin = "Global@Admin.com"   
                  
Connect-ExchangeOnline -UserPrincipalName $admin -ShowProgress $true #modify Admin please
 
# SCC / security and compliance
Connect-IPPSSession -UserPrincipalName $admin

Start-transcript
#####################################
$policies = Get-DlpCompliancePolicy
$policies | fl *guid*
 
foreach ($EP in $policies) {
Try { Set-DlpCompliancePolicy-identity $EP.Guid -RetryDistribution -confirm:$false } catch { write-host $error[0] }
Get-DlpCompliancePolicy-Identity $EP.Guid -DistributionDetail | FT Name,Type,ExchangeLocation,ExchangeLocationException,DistributionStatus,Enabled,Mode
Get-DlpCompliancePolicy-Identity $EP.Guid -DistributionDetail | select -ExpandProperty ExchangeLocationException }
################ end ####################
Stop-transcript