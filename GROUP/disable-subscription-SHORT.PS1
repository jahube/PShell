# disable Group Following

# check groups to know the valid Group data

Get-UnifiedGroup | FT name,displayname,primarySMTPaddress,ExternalDirectoryObjectId,HiddenFromAddressListsEnabled,HiddenFromExchangeClientsEnabled

# (1) ALL GROUPS
$groups = Get-UnifiedGroup

# (2) ONE GROUP
$groups = Get-UnifiedGroup -Identity "Algebra"

$groups = Get-UnifiedGroup -filter { name -like "*group*" } 

# (3) selected GROUPS
$Groupnames = "group1","group2","group3"

# run
$groups = $Groupnames | % { Set-UnifiedGroup -Identity $_ -SubscriptionEnabled:$false }