# check groups to know the valid Group data

Get-UnifiedGroup | FT name,displayname,primarySMTPaddress,ExternalDirectoryObjectId,HiddenFromAddressListsEnabled,HiddenFromExchangeClientsEnabled

$Groups = Get-DistributionGroup "group name"

# Searches inactive users
Foreach ($group in $groups) { $users =  Get-DistributionGroupMember $group.name
foreach ($user in $users) { $MBX = $() ; $MBX = get-mailbox $user.PrimarySmtpAddress -EA silentlycontinue
If (!($MBX)) {
write-host 'Group: [ "' $($group.name)'" ] has inactive Member: [ "'$($user.PrimarySmtpAddress)'" ] please remove' -F yellow
write-host 'Group: [ "' $($group.name)'" ] removing inactive Member: [ "'$($user.PrimarySmtpAddress)'" ]' -F yellow
Remove-DistributionGroupMember -Identity $group.name -Member $($user.PrimarySmtpAddress) -Confirm:$false }}}


# REMOVES inactive users
Foreach ($group in $groups) { $users =  Get-DistributionGroupMember $group.name
foreach ($user in $users) { $MBX = $() ; $MBX = get-mailbox $user.PrimarySmtpAddress -EA silentlycontinue
If (!($MBX)) {
write-host 'Group: [ "' $($group.name)'" ] has inactive Member: [ "'$($user.PrimarySmtpAddress)'" ] please remove' -F yellow
write-host 'Group: [ "' $($group.name)'" ] removing inactive Member: [ "'$($user.PrimarySmtpAddress)'" ]' -F yellow
Remove-DistributionGroupMember -Identity $group.name -Member $($user.PrimarySmtpAddress) -Confirm:$false }}}