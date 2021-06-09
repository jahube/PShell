unInstall-Module -Name AzureADPreview -AllVersions

Install-Module -Name AzureADPreview
Install-Module -Name AipService

$cred = get-credential

Connect-AzureAD -Credential $cred
Connect-AipService -Credential $cred

################ create filter ###################################################
# RMS_S_PREMIUM  RMS_S_PREMIUM2  RMS_S_ENTERPRISE

# group RMS serviceplans
$RMSPlan = ((Get-AzureADSubscribedSku).ServicePlans | Where { $_.ServicePlanName -like "RMS*" } | group ServicePlanName,ServicePlanId).Name

# group RMS serviceplan id
$RMSPlanID = ((Get-AzureADSubscribedSku).ServicePlans | Where { $_.ServicePlanName -like "RMS*" } | group ServicePlanId).Name

#  $filter = { user.assignedPlans -any (assignedPlan.servicePlanId -eq "5689bec4-755d-4753-8b61-40975025187c" -or assignedPlan.servicePlanId -eq "6c57d4b6-3b23-47a5-9bc9-69f17b4947b3" -or assignedPlan.servicePlanId -eq "bea4c11e-220a-4e6d-8eb8-8ea15d019f90" -and assignedPlan.capabilityStatus -eq "Enabled") }

#build plaintext
$filtertext = @"
user.assignedPlans -any (assignedPlan.servicePlanId -eq "$($RMSPlanID[0])" -or assignedPlan.servicePlanId -eq "$($RMSPlanID[1])" -or assignedPlan.servicePlanId -eq "$($RMSPlanID[2])" -and assignedPlan.capabilityStatus -eq "Enabled")
"@

# convert to scriptblock (filter format)
$filter = [scriptblock]::Create($filtertext)

################ create Group ###################################################

  $Param = @{ SecurityEnabled = $True
                  MailEnabled = $False
                  DisplayName = "Dynamic Group RMS"
                  Description = "Dynamic group created from PS"
                 MailNickName = "RMSlicensegroup"
                   GroupTypes = "DynamicMembership"
               MembershipRule = $filter
MembershipRuleProcessingState = "On" }

New-AzureADMSGroup @Param

############## check group + membership  ########################################

$group = get-AzureADMSGroup -SearchString "Dynamic Group RMS"
$members = Get-AzureADGroupMember -ObjectId $group[0].id

get-AzureADMSGroup -SearchString "Dynamic Group RMS" | % { Set-AzureADMSGroup -id $_.id -MembershipRuleProcessingState "paused" }

get-AzureADMSGroup -SearchString "Dynamic Group RMS" | % { Set-AzureADMSGroup -id $_.id -MembershipRuleProcessingState "on" }

get-AzureADMSGroup -SearchString "Dynamic Group RMS" | ft *yName,MembershipRuleP*

get-AzureADMSGroup -SearchString "Dynamic Group RMS" | fl *yName,MembershipRule*,id

############## assign Group as Scope  ##########################################

# Pick Group ID

get-AzureADMSGroup -SearchString "Dynamic Group RMS" | fl *yName,MembershipRule*,id

# Assign Group ID as Label criteria

Set-AipServiceOnboardingControlPolicy -UseRmsUserLicense $False -SecurityGroupObjectId "03445a4c-0e59-4e3e-b10d-0a9166f4fe5c" -Scope All

############## LIST SKU PLAN IDS ###############################################

$Data =@()

foreach ($SKU in (Get-AzureADSubscribedSku | Where { $_.ServicePlans.ServicePlanName -Match "RMS" }))
      { $PartNumber = $SKU.SkuPartNumber

             foreach ($ServicePlan in ($SKU.ServicePlans | Where { $_.ServicePlanName -Match "RMS" }))
          {
            $Object = [PSCustomObject]@{
         PartNumber = $PartNumber
    ServicePlanName = $ServicePlan.ServicePlanName
      ServicePlanId = $ServicePlan.ServicePlanId
 ProvisioningStatus = $ServicePlan.ProvisioningStatus
          AppliesTo = $ServicePlan.AppliesTo }
             $Data += [array]$Object
           }
       }

$Data | FT
($Data | group ServicePlanName,ServicePlanId).name