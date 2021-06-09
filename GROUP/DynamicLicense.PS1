user.assignedPlans -any (assignedPlan.servicePlanId -eq "b30d0d10-624f-4e70-8db2-24c3a772d46f" -and assignedPlan.capabilityStatus -eq "Enabled")

user.assignedPlans -any (assignedPlan.service -eq "SCO" -and assignedPlan.capabilityStatus -eq "Enabled")

"(user.department -contains ""Marketing"")"

  $Param = @{ SecurityEnabled = $True
                  MailEnabled = $False
                  DisplayName = "Dynamic Group 01" 
                  Description = "Dynamic group created from PS"
                 MailNickName = "group"
                   GroupTypes = "DynamicMembership"
               MembershipRule = "(user.assignedPlans -any (assignedPlan.servicePlanId -eq ""b30d0d10-624f-4e70-8db2-24c3a772d46f"" -and assignedPlan.capabilityStatus -eq ""Enabled""))"
MembershipRuleProcessingState = "On" }

New-AzureADMSGroup @Param

New-AzureADMSGroup -DisplayName "Dynamic Group 01" -Description "Dynamic group created from PS" -MailEnabled $False -MailNickName "group" -SecurityEnabled $True -GroupTypes "DynamicMembership" -MembershipRule "(user.department -contains ""Marketing"")" -MembershipRuleProcessingState "On"



unInstall-Module -Name AzureADPreview -AllVersions

Install-Module -Name AzureADPreview -scope currentuser

Connect-AzureAD

get-AzureADMSGroup -SearchString "Algebra" | % { Set-AzureADMSGroup -id $_.id -MembershipRuleProcessingState "paused" }

get-AzureADMSGroup -SearchString "Algebra" | % { Set-AzureADMSGroup -id $_.id -MembershipRuleProcessingState "on" }

get-AzureADMSGroup -SearchString "Algebra" | ft *yName,MembershipRuleP*


Set-AipServiceOnboardingControlPolicy -UseRmsUserLicense $False -SecurityGroupObjectId "GUID HERE" -Scope All