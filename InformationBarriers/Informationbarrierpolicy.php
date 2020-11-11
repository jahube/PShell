Import-Module Az.Accounts
Connect-AzAccount 
Get-AzADApplication
$appId = "bcf62038-e005-436d-b970-2a472f8c1982"
New-AzADServicePrincipal -ApplicationId "bcf62038-e005-436d-b970-2a472f8c1982"
Start-Process  "https://login.microsoftonline.com/common/adminconsent?client_id=$appId"

Connect-IPPSSession -UserPrincipalName admin@domain.com
Connect-ExchangeOnline -UserPrincipalName admin@domain.com
Get-Recipient | ? {$_.department -ne "" } | fl name,department
$department = (Get-Recipient | ? {$_.department -ne "" } | group department).name
#foreach ($department in $departments) { 
New-OrganizationSegment -name $department -UserGroupFilter "Department -eq 'Microsoft / LAB account'"
New-OrganizationSegment -name 'test5' -UserGroupFilter "Department -eq 'test5'"
New-OrganizationSegment -name 'test4' -UserGroupFilter "Department -eq 'test4'"
New-OrganizationSegment -name 'test5' -UserGroupFilter "Department -eq 'test3'"
New-OrganizationSegment -name 'test4' -UserGroupFilter "Department -eq 'test2'"
#}
New-InformationBarrierPolicy -Name 'LAB IB' -AssignedSegment 'Microsoft / LAB account' -SegmentsAllowed 'test3','test2','Microsoft / LAB account' -State active
New-InformationBarrierPolicy -Name 'LAB IB 2' -AssignedSegment 'test4' -SegmentsAllowed 'test4','test5' -State active
get-InformationBarrierPolicy
get-OrganizationSegment |ft
Start-InformationBarrierPoliciesApplication
get-InformationBarrierPolicy | ft
get-InformationBarrierPolicy | % { set-InformationBarrierPolicy -Identity $_.guid -State inactive }
get-InformationBarrierPolicy | % { remove-InformationBarrierPolicy -Identity $_.guid }
get-InformationBarrierPolicy | ft

Get-InformationBarrierPoliciesApplicationStatus -All
Get-InformationBarrierReportDetails
Get-InformationBarrierRecipientStatus
Get-InformationBarrierPoliciesApplicationStatus | Stop-InformationBarrierPoliciesApplication