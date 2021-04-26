
################################################################################
Create Teams / Channels
Invite Guest User from CSV

Install Modules Teams + AzureAD incl. latest Repository / TLS 1.2 Fixes
Note (-) sending Teams Group link directly currently > Spam
      +  user can directly find the link
      +  Easy buld operation Guest + Teams group
      +  Fixes + Setup

Alternative: Send second mail
$Invitation = New-AzureADMSInvitation 
Above will store the Data necessary to automate second Mail which then does not go to spam

Background: first mail sent from invites@microsoft.com

Alternative: create Transport Rule in Target Tenant(s) to change expected SCL 9 to 1

Semder = invites@microsoft.com >> change message properties SCL 1

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

Install-Module ExchangeonlineManagement

Connect-Exchangeonline -credential $cred

##########################################################################
##     the below to get Teams latest Beta + trust + TLS 1.2       ##
##########################################################################
# Tls12
If ([Net.ServicePointManager]::SecurityProtocol -ne "Tls12") {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 }

# PSRepository PSGallery
if (!(get-PSRepository PSGallery -ErrorAction SilentlyContinue)) { Register-PSRepository -Default }

try { Install-PackageProvider -Name NuGet -Force -ErrorAction Stop } catch { Install-PackageProvider -Name NuGet -Force -Scope CurrentUser }

# Trust PSGallery
if ((get-PSRepository PSGallery -ErrorAction SilentlyContinue).InstallationPolicy -ne "Trusted") { Set-PSRepository -Name "PSGallery" -InstallationPolicy "Trusted" }

# get-pssession | Remove-PSSession

#ExchangeonlineManagement
if ((Get-InstalledModule ExchangeonlineManagement -ErrorAction SilentlyContinue).Version -lt "2.0.0")
{
Write-Host "ExchangeonlineManagement Version $((Get-InstalledModule ExchangeonlineManagement -ErrorAction SilentlyContinue).Version) already installed" -F green
Uninstall-Module ExchangeonlineManagement -AllVersions -Force -ErrorAction SilentlyContinue -Confirm:$false
try { Install-Module ExchangeonlineManagement -Force -Confirm:$false -EA stop } catch { Install-Module ExchangeonlineManagement -Force -Scope CurrentUser -Confirm:$false }
Write-Host "Now ExchangeonlineManagement Version $((Get-InstalledModule ExchangeonlineManagement -ErrorAction SilentlyContinue).Version) installed" -F cyan
} else { Write-Host "ExchangeonlineManagement Version $((Get-InstalledModule ExchangeonlineManagement -ErrorAction SilentlyContinue).Version) already installed" -F green  }

#AzureAD
if ((Get-InstalledModule AzureADpreview -ErrorAction SilentlyContinue).Version -lt "2.0.0" -and (Get-InstalledModule AzureAD -ErrorAction SilentlyContinue).Version -le "2.0.0")
{write-host "test"
Uninstall-Module AzureADpreview -AllVersions -Force -ErrorAction SilentlyContinue -Confirm:$false
Uninstall-Module AzureAD -AllVersions -Force -ErrorAction SilentlyContinue -Confirm:$false
try { Install-Module AzureADpreview -Force -Confirm:$false -EA stop } catch { Install-Module AzureADpreview -Force -Scope CurrentUser -Confirm:$false }
Write-Host "Now AzureADpreview Version $((Get-InstalledModule AzureADpreview -ErrorAction SilentlyContinue).Version) installed" -F cyan
} else { Write-Host "AzureADpreview Version $((Get-InstalledModule AzureADpreview -ErrorAction SilentlyContinue).Version) already installed" -F green  }

<#
#Teams
if ((Get-InstalledModule MicrosoftTeams -ErrorAction SilentlyContinue).Version -lt "2.0.0")
{
Uninstall-Module MicrosoftTeams -AllVersions -Force -Confirm:$false
try { Install-Module MicrosoftTeams -Force -Confirm:$false -EA stop } catch { Install-Module MicrosoftTeams -Force -Scope CurrentUser -Confirm:$false }
Write-Host "Now MicrosoftTeams Version $((Get-InstalledModule MicrosoftTeams -ErrorAction SilentlyContinue).Version) installed" -F cyan
} else { Write-Host "MicrosoftTeams Version $((Get-InstalledModule MicrosoftTeams -ErrorAction SilentlyContinue).Version) already installed" -F green  }
#>

#Teams latest Preview

$latestversion = (Find-Module MicrosoftTeams -AllowPrerelease -AllVersions| Sort-Object version -Descending)[0].version

if ((Get-InstalledModule MicrosoftTeams -ErrorAction SilentlyContinue).Version -ne $latestversion )
{
Uninstall-Module MicrosoftTeams -AllVersions -Force -Confirm:$false
Install-Module PowerShellGet -Force -AllowClobber

try { Install-Module MicrosoftTeams -AllowPrerelease -RequiredVersion $latestversion -Force -Confirm:$false -EA stop } catch { Install-Module MicrosoftTeams -AllowPrerelease -RequiredVersion $latestversion -Force -Scope CurrentUser -Confirm:$false }
Write-Host "Now MicrosoftTeams Version $((Get-InstalledModule MicrosoftTeams -ErrorAction SilentlyContinue).Version) installed" -F cyan
} else { Write-Host "MicrosoftTeams Version $((Get-InstalledModule MicrosoftTeams -ErrorAction SilentlyContinue).Version) already installed" -F green  }

#MSOnline
if ((Get-InstalledModule MSOnline -ErrorAction SilentlyContinue).Version -lt "1.1.0.0")
{
Uninstall-Module MSOnline -AllVersions -Force -ErrorAction SilentlyContinue -Confirm:$false
try { Install-Module MSOnline -Force -Confirm:$false -EA stop } catch { Install-Module MSOnline -Force -Scope CurrentUser -Confirm:$false }
Write-Host "Now MSOnline Version $((Get-InstalledModule MSOnline -ErrorAction SilentlyContinue).Version) installed" -F cyan
} else { Write-Host "MSOnline Version $((Get-InstalledModule MSOnline -ErrorAction SilentlyContinue).Version) already installed" -F green  }


Connect-MicrosoftTeams -Credential $cred

Connect-AzureAD -Credential $cred

Connect-MsolService -Credential $cred

Function ConnectTeams
{
If (! (get-team -ErrorAction SilentlyContinue))
     {
Write-Host "Teams not connected" -F Yellow
Connect-MicrosoftTeams -Credential $cred
Write-Host "Now Teams connected" -F cyan }
else { Write-Host "Teams already connected" -F green }
}

ConnectTeams

##########################################################################
##                       create group / channel                         ##
##########################################################################
$GroupName = "TESTGROUP16" # please modify

#$ADMIN = "admin@domain.com" # please modify

ConnectTeams

$ObjectId = (New-Team -DisplayName $GroupName -Owner $ADMIN).GroupId

# $ObjectId = (get-Team -DisplayName $GroupName).GroupId
# $ObjectId = (get-msolgroup -SearchString $GroupName).ObjectId.Guid

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
create CSV via powershell insert list below
##########################################################################

$textblock = @"
Email,FirstName,SurName,Jobtitle,Company
jdoe@host.cloudns.cl,John,Doe,IT,MS
jane@host.cloudns.cl,Jane,Doe,IT,MS
"@

$textblock > "C:\TeamsUserList.csv" # save above as CSV

################## mobile optional #######################################
Email,FirstName,SurName,Jobtitle,Company,Mobile
jdoe@a.com,John,Doe,IT,MS,+112345
##########################################################################

##########################################################################
$CSVPath = "C:\TeamsUserList.CSV" # change file Path
##########################################################################
$data = @()
$data =  Import-Csv $CSVPath # -Encoding UTF7 / UTF8 # -Delimiter ':' / ';'
foreach ($contact in $data) { ConnectTeams
  $Mailadress = $contact.Email
  #$Mailadress = "Jane@host.cloudns.cl"
  $FirstName = $contact.FirstName
  $SurName = $contact.SurName
  $FullName= $FirstName+" "+$SurName
  $Company = "Ext: "+$contact.Company
  $JobTitle = $contact.JobTitle
  # $Mobile = $contact.Mobile # uncomment if added above
  $MessageInfo = New-Object Microsoft.Open.MSGraph.Model.InvitedUserMessageInfo #Update the line with the teams url copied to a notepad
 
  $MessageInfo.CcRecipients = New-Object Microsoft.Open.MSGraph.Model.Recipient
  [Microsoft.Open.MSGraph.Model.Recipient]@("admin@edu.dnsabr.com")

$recipient2 = New-Object Microsoft.Open.MSGraph.Model.Recipient
$emailAddress = New-Object Microsoft.Open.MSGraph.Model.EmailAddress
$emailAddress.Name = "Admin2"
$emailAddress.Address = $ADMIN
$recipient2.EmailAddress = $emailAddress
$messageInfo.CcRecipients += $recipient2
$messageInfo.MessageLanguage = "en-US"
# $messageInfo | fl * -f
  #$TeamsURL = "https://teams.microsoft.com/_?tenantId=27ea7a4a-fcff-4a67-97c5-dd6db39b9489#/conversations/General?threadId=19:50f1d76192bd4d6e9c92cb8b343f81e3"
  $MessageInfo.customizedMessageBody = "Dear $FirstName , I created an invitation through PowerShell, please join to add Teams Channel below"
  $MessageInfo.customizedMessageBody
# This is the real cmdlet that does send the message, it makes use of all the data we have loaded/cache above

 $Param = @{ InvitedUserDisplayName = $FullName
            InvitedUserEmailAddress = $Mailadress
             InvitedUserMessageInfo = $messageInfo
              SendInvitationMessage = $true
                  InviteRedirectURL = "https://myapplications.microsoft.com" }

  Try { $Invitation = New-AzureADMSInvitation @Param -ErrorAction Stop
         Write-Host "$FullName : $Mailadress successfully invited" -F green }
catch { $Error[0].InvocationInfo | FL * -F
Write-Host "$FullName : $Mailadress invitation failed`n $($Error[0].Message)" -F yellow }

$Invitation | fl * -f

$user = Get-AzureADUser -ObjectId $invitation.InvitedUser.Id

$Param = @{ Surname = $SurName
          GivenName = $Firstname
        Displayname = $FullName
           JobTitle = $JobTitle
         Department = $Company }

Set-AzureADUser -ObjectId $invitation.InvitedUser.Id @Param

<#
Set-AzureADUser -ObjectId $invitation.InvitedUser.Id -Surname $SurName
Set-AzureADUser -ObjectId $invitation.InvitedUser.Id -GivenName $Firstname
Set-AzureADUser -ObjectId $invitation.InvitedUser.Id -Displayname $user.Displayname
Set-AzureADUser -ObjectId $invitation.InvitedUser.Id -JobTitle $JobTitle
Set-AzureADUser -ObjectId $invitation.InvitedUser.Id -Department $Company
# Set-AzureADUser -ObjectId $invitation.InvitedUser.Id -Mobile $Mobile  #uncomment
#>

##########################################################################
#  Add Teamuser
##########################################################################
  try { Add-TeamUser -GroupId $ObjectId -user $Mailadress -ErrorAction Stop
Write-Host "$FullName : $Mailadress successfully added to Team" -F green }
catch { $Error[0].InvocationInfo | FL * -F
Write-Host "$FullName : $Mailadress adding to Team failed`n $($Error[0].Message)" -F yellow }

################################################################################
#  Add TeamChannelUser - only works for Teams created as -MembershipType Private
################################################################################
  Try { Add-TeamChannelUser -GroupId $ObjectId -DisplayName $Channel2 -user $Mailadress -ErrorAction Stop
Write-Host "$FullName : $Mailadress successfully added to Channel ['"'$Channel2'"']" -F green }
catch { $Error[0].InvocationInfo | FL * -F
Write-Host "$FullName : $Mailadress adding to Channel [$Channel2] failed`n $($Error[0].Message)" -F yellow }
# Add-TeamChannelUser -GroupId $ObjectId -DisplayName $Channel2 -user $Mailadress -Role Owner
}

(get-AzureADuser -filter "mail eq 'jdoe@host.cloudns.cl'") | ft mail,DisplayName,createddatetime,userstate
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