
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

$userguid1 = (get-user $user1).ExternalDirectoryObjectId
$userguid2 = (get-user $user2).ExternalDirectoryObjectId

Write-host "Members Group 1"
$Members1 = Get-UnifiedGroupLinks $group1.ExternalDirectoryObjectId -LinkType Members ; $Members1

Write-host "Owners Group 1"
$Owners1 = Get-UnifiedGroupLinks -Identity $group1.ExternalDirectoryObjectId -LinkType Owners ; $Owners1

Write-host "Members Group 2"
$Members2 = Get-UnifiedGroupLinks $group2.ExternalDirectoryObjectId -LinkType Members ; $Members2

Write-host "Owners Group 2"
$Owners2 = Get-UnifiedGroupLinks -Identity $group2.ExternalDirectoryObjectId -LinkType Owners ; $Owners2

Write-host "TeamUser Group 1"
Get-TeamUser -GroupId $group1.ExternalDirectoryObjectId -Role member
Get-TeamUser -GroupId $group1.ExternalDirectoryObjectId -Role Owner

Write-host "TeamUser Group 2"
Get-TeamUser -GroupId $group2.ExternalDirectoryObjectId -Role member
Get-TeamUser -GroupId $group2.ExternalDirectoryObjectId -Role Owner

Write-host "Get-Team Group 1"
get-team -GroupId $group1.ExternalDirectoryObjectId |fl

Write-host "Get-Team Group 2"
get-team -GroupId $group2.ExternalDirectoryObjectId |fl

Write-host "Get-Team USER 1"
Get-Team -User $user1
Write-host "Get-Team USER 2"
Get-Team -User $user2
Get-AzureADUser -ObjectId $userguid1 |fl
Get-MsolUser -ObjectId $userguid1  |fl
Get-AzureADUser -ObjectId $userguid2 |fl
Get-MsolUser -ObjectId $userguid2  |fl

Stop-Transcript

#end