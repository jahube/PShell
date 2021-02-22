################################################################################
Create Teams / Channels
Invite Guest User from CSV

Install Modules Teams + AzureAD incl latest REpository / TLS 1.2 Fixes
Note (-) sending Teams Group link directly currently > Spam
      +  user can directly find the link
      +  Easy buld operation Guest + Teams group
      +  Fixes + Setup

Alternative: remove the link + custom text > Inbox instead of Spam
################################################################################
###  User exp  https://docs.microsoft.com/en-us/azure/active-directory/b2b/redemption-experience     ####
################################################################################
# HINT https://docs.microsoft.com/en-us/microsoftteams/guest-access-checklist ##
################################################################################

https://docs.microsoft.com/en-us/microsoftteams/guest-access-checklist

Set-ExecutionPolicy RemoteSigned -Force

$ADMIN = "admin@domain.com"

Get-Credential $ADMIN | Export-Clixml $ENV:UserProfile\Documents\MyCredential.xml
$cred = Import-Clixml $ENV:UserProfile\Documents\MyCredential.xml

Install-Module-ExchangeonlineManagement

Connect-Exchangeonline -credential $cred

##########################################################################
##     the stunt below to get Teams latest Beta + trust + TLS 1.2       ##
##########################################################################

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name NuGet -Force -Scope CurrentUser

Install-module AzureAD -scope CurrentUser

Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

# get-pssession | Remove-PSSession

Uninstall-Module MicrosoftTeams -AllVersions

Install-Module MicrosoftTeams

# Install-Module MSOnline -scope currentuser -Force
# Connect-MsolService -Credential $cred

Connect-MicrosoftTeams -Credential $cred

Connect-AzureAD -Credential $cred

##########################################################################
##                       create group / channel                         ##
##########################################################################
$GroupName = "TESTGROUP4" # please modify
$ADMIN = "admin@domain.com" # please modify
New-Team -DisplayName $GroupName -Owner $ADMIN
$ObjectId = (get-msolgroup -SearchString $GroupName).ObjectId.Guid
# $GroupID = (get-Team -DisplayName "TESTGROUP").GroupId #alternative/slower
set-Team -GroupId $ObjectId -DisplayName $GroupName -AllowUserEditMessages $true -AllowOwnerDeleteMessages $true -Visibility Public # Private
$Channel1 = "Channel Name"
New-TeamChannel -GroupId $ObjectId -DisplayName $Channel1
$Channel2 = "Private Channel Name"
New-TeamChannel -GroupId $ObjectId -DisplayName $Channel2 -owner $ADMIN -MembershipType Private
##########################################################################
##                             Invitation                               ##
##########################################################################
$GroupName = "TESTGROUP4" # please modify
$ObjectId = (get-msolgroup -SearchString $GroupName).ObjectId.Guid
##########################################################################
#     create CSV File in Notepad and save as CSV + change file Path     ##
##########################################################################

################ CSV Example #############################################
Email,FirstName,SurName,Jobtitle,Company
jdoe@a.com,John,Doe,IT,MS
jane@a.com,Jane,Doe,IT,MS
##########################################################################

################## mobile optional #######################################
Email,FirstName,SurName,Jobtitle,Company,Mobile
jdoe@a.com,John,Doe,IT,MS,+112345
##########################################################################

##########################################################################
$CSVPath = "C:\TeamsUserList.CSV" # change file Path
##########################################################################
$data = @()
$data =  Import-Csv $CSVPath # -Encoding UTF7 / UTF8 # -Delimiter ':' / ';'
foreach ($contact in $data) {
  $Mailadress = $contact.Email
  $FirstName = $contact.FirstName
  $SurName = $contact.SurName
  $FullName= $FirstName+" "+$SurName
  $Company = "Ext: "+$contact.Company
  $JobTitle = $contact.JobTitle
  # $Mobile = $contact.Mobile # uncomment if added above
  $MessageInfo = New-Object Microsoft.Open.MSGraph.Model.InvitedUserMessageInfo #Update the line with the teams url copied to a notepad
  $TeamsURL = "https://teams.microsoft.com/_?tenantId=27ea7a4a-fcff-4a67-97c5-dd6db39b9489#/conversations/General?threadId=19:50f1d76192bd4d6e9c92cb8b343f81e3"
  $MessageInfo.customizedMessageBody = "Dear $FirstName , I created an invitation through PowerShell, please join to add Teams Channel below"

# This is the real cmdlet that does send the message, it makes use of all the data we have loaded/cache above
$Invitation = New-AzureADMSInvitation `
  -InvitedUserDisplayName $FullName `
  -InvitedUserEmailAddress $Mailadress `
  -InvitedUserMessageInfo $messageInfo `
  -SendInvitationMessage $true `
  -InviteRedirectURL $TeamsURL 
$user = Get-AzureADUser -ObjectId $invitation.InvitedUser.Id
Set-AzureADUser -ObjectId $invitation.InvitedUser.Id -Surname $SurName
Set-AzureADUser -ObjectId $invitation.InvitedUser.Id -GivenName $Firstname
Set-AzureADUser -ObjectId $invitation.InvitedUser.Id -Displayname $user.Displayname
Set-AzureADUser -ObjectId $invitation.InvitedUser.Id -JobTitle $JobTitle
Set-AzureADUser -ObjectId $invitation.InvitedUser.Id -Department $Company
# Set-AzureADUser -ObjectId $invitation.InvitedUser.Id -Mobile $Mobile  #uncomment
##########################################################################
#  Add Teamuser
##########################################################################
Add-TeamUser -GroupId $ObjectId -user $Mailadress
################################################################################
#  Add TeamChannelUser - only works for Teams created as -MembershipType Private
################################################################################
Add-TeamChannelUser -GroupId $ObjectId -DisplayName $Channel2 -user $Mailadress
# Add-TeamChannelUser -GroupId $ObjectId -DisplayName $Channel2 -user $Mailadress -Role Owner
}
################################################################################
#                                 Ressources                                  ##
################################################################################
# https://docs.microsoft.com/en-us/azure/active-directory/b2b/bulk-invite-powershell
# FYI https://docs.microsoft.com/en-us/azure/active-directory/b2b/google-federation
# https://techcommunity.microsoft.com/t5/microsoft-teams/problem-with-google-accounts-and-microsoft-teams/m-p/334254#
# https://www.sharepointeurope.com/adding-guest-users-azure-ad-excel-powershell/
# https://stackoverflow.com/questions/35296482/invalid-web-uri-error-on-register-psrepository
# https://chrome.google.com/webstore/detail/refined-microsoft-teams/bipffdldhfhcecjhcgklheahpkocojfk/related
# https://blogs.technet.microsoft.com/skypehybridguy/2017/09/20/microsoft-teams-enabling-and-using-guest-access/
# https://github.com/MicrosoftDocs/office-docs-powershell/issues/2635
# https://microsoftteams.uservoice.com/forums/555103-public/suggestions/33799987-solution-for-guests-accounts-with-an-organisation
# https://docs.microsoft.com/en-us/azure/active-directory/b2b/add-users-administrator
# https://docs.microsoft.com/en-us/azure/active-directory/b2b/delegate-invitations
# https://github.com/ollij/PowerShell_Automating_ExternalUsers/blob/master/Demo-1-InviteUsers/Invite-ExternalUsers.ps1
# https://docs.microsoft.com/en-us/azure/active-directory/b2b/troubleshoot
# https://stackoverflow.com/questions/35296482/invalid-web-uri-error-on-register-psrepository/35296483#35296483
# https://techcommunity.microsoft.com/t5/microsoft-teams/teams-powershell-updating-microsoftteams-module/m-p/1250456#
# https://docs.microsoft.com/en-us/archive/blogs/skypehybridguy/microsoft-teams-enabling-and-using-guest-access
# https://justidm.wordpress.com/2017/05/07/azure-ad-b2b-how-to-bulk-add-guest-users-without-invitation-redemption/
# https://tomtalks.blog/2018/03/add-external-users-email-address-guest-microsoft-teams/
# https://docs.microsoft.com/en-us/microsoftteams/guest-access-checklist
# https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/add-external-user?view=azure-devops&tabs=preview-page
# https://docs.microsoft.com/en-us/azure/active-directory/b2b/invitation-email-elements
# https://docs.microsoft.com/en-us/azure/active-directory/b2b/code-samples
# https://blog.kloud.com.au/2017/09/19/automatically-provision-azure-ad-b2b-guest-accounts/

