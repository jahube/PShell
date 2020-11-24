# https://www.knowledgebase.it/powershell/install-azure-active-directory-in-powershell/fixoffice365groupsubscriptions/

# All Office 365 Groups
#$groups = Get-UnifiedGroup

# One Office 365 group
#$groups = Get-UnifiedGroup -Identity "Group"

foreach ($group in $groups) {

$members = Get-UnifiedGroupLinks -Identity $group.Name -LinkType Members

$subscribers = Get-UnifiedGroupLinks -Identity $group.Name -LinkType Subscribers

foreach ($member in $members) {
If ($member.Name -notin $subscribers.Name) {Add-UnifiedGroupLinks -Identity $group.Name -LinkType Subscribers -Links $member.Name } 
                              }

}