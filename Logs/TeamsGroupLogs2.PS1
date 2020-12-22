
Set-ExecutionPolicy RemoteSigned

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

$Groupname = “Group name 1"

$Groupname = “Group name 2"

$group1 = Get-UnifiedGroup -Identity $Groupname ; $group1 |fl

$group2 = Get-UnifiedGroup -Identity $Groupname ; $group2 |fl

Write-host "Members Group 1"
$Members1 = Get-UnifiedGroupLinks $group1.ExternalDirectoryObjectId -LinkType Members ; $Members1

Write-host "Owners Group 1"
$Owners1 = Get-UnifiedGroupLinks -Identity $group1.ExternalDirectoryObjectId -LinkType Owners ; $Owners1

Write-host "Members Group 2"
$Members2 = Get-UnifiedGroupLinks $group2.ExternalDirectoryObjectId -LinkType Members ; $Members2

Write-host "Owners Group 2"
$Owners2 = Get-UnifiedGroupLinks -Identity $group2.ExternalDirectoryObjectId -LinkType Owners ; $Owners2

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