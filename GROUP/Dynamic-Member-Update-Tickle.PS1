# ticking for AzureADMSGroup PAUSED > ON will update the members

# Works ONLY after latest UPDATE below

unInstall-Module -Name AzureADPreview -AllVersions

Install-Module -Name AzureADPreview -scope currentuser

Connect-AzureAD

get-AzureADMSGroup -SearchString "Algebra" | % { Set-AzureADMSGroup -id $_.id -MembershipRuleProcessingState "paused" }

get-AzureADMSGroup -SearchString "Algebra" | % { Set-AzureADMSGroup -id $_.id -MembershipRuleProcessingState "on" }

get-AzureADMSGroup -SearchString "Algebra" | ft *yName,MembershipRuleP*