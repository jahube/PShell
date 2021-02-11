Remove Org Holds for a Mailbox

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Set-ExecutionPolicy RemoteSigned
Install-Module -Name ExchangeOnlineManagement

################# connect#############
$ADMIN = "admin@domain.com"                          # <-- modify admin
# Connect-ExchangeOnline -UserPrincipalName $ADMIN
Connect-IPPSSession -UserPrincipalName $ADMIN
#####################################

$user = "affected@user.com"              # <-- modify affected user

$policies = Get-RetentionCompliancePolicy

$policies | fl *guid*

######### Exo policy exclusion ##########
$EXO = $policies | where { $_.TeamsPolicy -eq $false } ; foreach ($EP in $EXO) {
Set-RetentionCompliancePolicy -Identity $EP.Guid -AddExchangeLocationException $user -confirm:$false
Set-RetentionCompliancePolicy -identity $EP.Guid -RetryDistribution -confirm:$false
Get-RetentionCompliancePolicy -Identity $EP.Guid -DistributionDetail | FT Name,Type,ExchangeLocation*,DistributionStatus,Enabled,Mode
Get-RetentionCompliancePolicy -Identity $EP.Guid -DistributionDetail | select -ExpandProperty ExchangeLocationException  }
################ end ####################

######### Teams policy exclusion #########
$teams = $policies | where { $_.TeamsPolicy -EQ $TRUE } ; foreach ($TP in $teams) {
Set-TeamsRetentionCompliancePolicy -Identity $TP.Guid -AddTeamsChatLocationException $user -confirm:$false
Set-TeamsRetentionCompliancePolicy -identity $TP.Guid -RetryDistribution -confirm:$false
Get-TeamsRetentionCompliancePolicy -Identity $TP.Guid -DistributionDetail | FT Name,Type,TeamsChatLocation*,DistributionStatus,Enabled,Mode
Get-TeamsRetentionCompliancePolicy -Identity $TP.Guid -DistributionDetail | select -ExpandProperty TeamsChatLocationException }
################ end ####################
 
######### Hold policy exclusion #########
$Holds = Get-HoldCompliancePolicy ; foreach ($H in $Holds) {
Set-HoldCompliancePolicy -Identity $H.GUID -RemoveExchangeLocation $user -confirm:$false
Set-HoldCompliancePolicy -Identity $H.GUID -RetryDistribution -confirm:$false
Get-HoldCompliancePolicy -Identity $H.GUID -DistributionDetail | FT *location* }
################ end ####################

Get-ComplianceSearch 

######### Hold policy exclusion #########
$search = Get-ComplianceSearch #| where { $_.ExchangeLocation -match 'all'} ; 
foreach ($S in $search) {
Set-ComplianceSearch -Identity $S.Identity -RemoveExchangeLocation $user -CF:$false
Set-ComplianceSearch -Identity $S.Identity -AddExchangeLocationExclusion $user -CF:$false
Set-ComplianceSearch -Identity $S.Identity -RetryDistribution -confirm:$false
Get-ComplianceSearch -Identity $S.Identity | FT *location*  }
################ end ####################
