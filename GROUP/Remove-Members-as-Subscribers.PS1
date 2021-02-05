# Remove Group Follower + Hide

# check groups to know the valid Group data

Get-UnifiedGroup | FT name,displayname,primarySMTPaddress,ExternalDirectoryObjectId,HiddenFromAddressListsEnabled,HiddenFromExchangeClientsEnabled

# (1) ALL GROUPS
$groups = Get-UnifiedGroup

# (2) ONE GROUP
$groups = Get-UnifiedGroup -Identity "group1"

$groups = Get-UnifiedGroup -filter { name -like "*group*" } 

# (3) selected GROUPS
$Groupnames = "group1","group2","group3"
$groups = $Groupnames | % { Get-UnifiedGroup -Identity $_ }

#    $groups | % { Set-UnifiedGroup $_.name -HiddenFromAddressListsEnabled:$false -HiddenFromExchangeClientsEnabled:$false }
#    $groups | % { Set-UnifiedGroup $_.name -SubscriptionEnabled:$true }

# SUBSCRIBE ALL

foreach ($group in $groups) {

if ($group.SubscriptionEnabled) {

Set-UnifiedGroup $group.name -SubscriptionEnabled:$false

   Write-host "Group [$($group.Name)] - [$($group.DisplayName)]"  -F yellow  -NoNewline ;   
   Write-host " [subscription ON]" -F white -NoNewline
   Write-host "  - Now [DISABLED] successfully `n( waiting 5 seconds replication time ) " -F green  
   Start-Sleep 5
       } else {

   Write-host "Group [$($group.Name)] - [$($group.DisplayName)]"  -F cyan  -NoNewline ; 
   Write-host " [subscription DISABLED]" -F green
               }


if (!($group.HiddenFromAddressListsEnabled)) { 

Set-UnifiedGroup $group.name -HiddenFromAddressListsEnabled:$true

   Write-host "Group [$($group.Alias)] - [$($group.DisplayName)]"  -F yellow  -NoNewline ;   
   Write-host " [HiddenFromAddressLists DISABLED]" -F white -NoNewline
   Write-host "  - Now [ENABLED/Hidden] successfully " -F green  
  
       } else {

   Write-host "Group [$($group.Name)] - [$($group.DisplayName)]"  -F cyan  -NoNewline ; 
   Write-host " [HiddenFromAddressLists ON]" -F green
               }

if (!($group.HiddenFromExchangeClientsEnabled)) { 

Set-UnifiedGroup $group.name -HiddenFromExchangeClientsEnabled:$true

   Write-host "Group [$($group.Name)] - [$($group.DisplayName)]"  -F yellow  -NoNewline ;   
   Write-host " [HiddenFromExchangeClientsEnabled DISABLED]" -F white -NoNewline
   Write-host "  - Now [ON/Hidden] successfully " -F green  
  
       } else {

   Write-host "Group [$($group.Name)] - [$($group.DisplayName)]"  -F cyan  -NoNewline ; 
   Write-host " [HiddenFromExchangeClientsEnabled ON]" -F green
               }

$members = Get-UnifiedGroupLinks -Identity $group.Name -LinkType Members

   Write-host " Members $($members.count)" -F Magenta

$Owners = Get-UnifiedGroupLinks -Identity $group.Name -LinkType Owners

   Write-host " Owners $($Owners.count)" -F Magenta

$subscribers = Get-UnifiedGroupLinks -Identity $group.Name -LinkType Subscribers

   Write-host " subscribers $($subscribers.count)1`n" -F Green

foreach ($member in $members) { If ($member.Name -in $subscribers.Name) {

 Remove-UnifiedGroupLinks -Identity $group.Name -LinkType Subscribers -Links $member.Name

   Write-host "Subscriber " -F white -NoNewline
   Write-host "$($member.Name)" -F yellow -NoNewline
   Write-host " Removed from " -F Green -NoNewline
   Write-host "[Group] $($group.Name) - [$($group.DisplayName)]" -F white 
 
        } else { 

   Write-host "subscriber " -F white -NoNewline
   Write-host "$($member.Name)" -F green -NoNewline
   Write-host " already removed from " -F yellow -NoNewline
   Write-host "[Group] $($group.Name)  - [$($group.DisplayName)]" -F white 

                } 
         } 

}

# End #

# rewritten - inspired by https://www.knowledgebase.it/powershell/install-azure-active-directory-in-powershell/fixoffice365groupsubscriptions/
