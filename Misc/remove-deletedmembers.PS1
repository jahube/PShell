# check groups to know the valid Group data

Get-UnifiedGroup | FT name,displayname,primarySMTPaddress,ExternalDirectoryObjectId,HiddenFromAddressListsEnabled,HiddenFromExchangeClientsEnabled

$Groups = Get-DistributionGroup "group name"

# Searches inactive users
Foreach ($group in $groups) { $users =  Get-DistributionGroupMember $group.name -resultsize unlimited
foreach ($user in $users) { $MBX = $() ; $MBX = get-mailbox $user.PrimarySmtpAddress -EA silentlycontinue
If (!($MBX)) {
write-host 'Group: [ "' $($group.name)'" ] has inactive Member: [ "'$($user.PrimarySmtpAddress)'" ] please remove' -F yellow
write-host 'Group: [ "' $($group.name)'" ] removing inactive Member: [ "'$($user.PrimarySmtpAddress)'" ]' -F yellow
Remove-DistributionGroupMember -Identity $group.name -Member $($user.PrimarySmtpAddress) -Confirm:$false }}}


# REMOVES inactive users
Foreach ($group in $groups) { $users =  Get-DistributionGroupMember $group.name -resultsize unlimited
foreach ($user in $users) { $MBX = $() ; $MBX = get-mailbox $user.PrimarySmtpAddress -EA silentlycontinue
If (!($MBX)) {
write-host 'Group: [ "' $($group.name)'" ] has inactive Member: [ "'$($user.PrimarySmtpAddress)'" ] please remove' -F yellow
write-host 'Group: [ "' $($group.name)'" ] removing inactive Member: [ "'$($user.PrimarySmtpAddress)'" ]' -F yellow
Remove-DistributionGroupMember -Identity $group.name -Member $($user.PrimarySmtpAddress) -Confirm:$false }}}


# REMOVES inactive users distinguishedname
Foreach ($group in $groups) { $users =  Get-DistributionGroupMember $group.name -resultsize unlimited
foreach ($user in $users) { $MBX = $() ; $MBX = get-mailbox $user.PrimarySmtpAddress -EA silentlycontinue
If (!($MBX)) {
write-host 'Group: [ "' $($group.name)'" ] has inactive Member: [ "'$($user.name)'" ] please remove' -F yellow
write-host 'Group: [ "' $($group.name)'" ] removing inactive Member: [ "'$($user.PrimarySmtpAddress)'" ]' -F yellow
Remove-DistributionGroupMember -Identity $group.name -Member $($user.Distinguishedname) -Confirm:$false }}}

# REMOVES inactive users distinguishedname / different style
Foreach ($group in $groups) { $users =  Get-DistributionGroupMember $group.name  -ResultSize
foreach ($user in $users) { $MBX = $() ; $MBX = get-mailbox $user.PrimarySmtpAddress -EA silentlycontinue
If (!($MBX)) {
write-host "Group: [$($group.name)] has inactive Member: [$($user.name)] [$($user.PrimarySmtpAddress)] please remove" -F yellow
write-host "Group: [$($group.name)] removing inactive Member: [$($user.name)] [$($user.PrimarySmtpAddress)]" -F yellow
Remove-DistributionGroupMember -Identity $group.name -Member $($user.distinguishedname) -Confirm:$false }}}