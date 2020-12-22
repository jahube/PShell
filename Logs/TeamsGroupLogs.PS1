# install
install-module MSOnline
install-module MicrosoftTeams
install-module ExchangeOnlineManagement
install-module AzureADPreview

# connect
$cred = get-credential ADMIN

Connect-MsolService -Credential $cred
Connect-MicrosoftTeams -Credential $cred
Connect-ExchangeOnline -Credential $cred
Connect-AzureAD -Credential $cred

# Start

Start-Transcript

$user1 = "user1@example.com"

$user2 = "user2@example.com"

$Groupname = “Group name"

$group = Get-UnifiedGroup -Identity “PineviewSchoolStaff" ; $group |fl
Write-host "Members"
$Members = Get-UnifiedGroupLinks $group.ExternalDirectoryObjectId -LinkType Members ; $Members
Write-host "Owners"
$Owners = Get-UnifiedGroupLinks -Identity $group.ExternalDirectoryObjectId -LinkType Owners ; $Owners
$userguid1 = (get-user $user1).ExternalDirectoryObjectId
$userguid2 = (get-user $user2).ExternalDirectoryObjectId
Get-Team -User $user1
Get-Team -User $user2
Get-TeamUser -GroupId $group.ExternalDirectoryObjectId -Role member
Get-TeamUser -GroupId $group.ExternalDirectoryObjectId -Role Owner
Get-AzureADUser -ObjectId $userguid1 |fl
Get-MsolUser -ObjectId $userguid1  |fl
Get-AzureADUser -ObjectId $userguid2 |fl
Get-MsolUser -ObjectId $userguid2  |fl
get-team -GroupId $group.ExternalDirectoryObjectId |fl

Stop-Transcript

#end