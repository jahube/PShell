# (1) Follow Group in Inbox + enable Subscription              - [ISSUE: Emails only in Group Mailbox + (2) = "don't get emails"]
# (2) Un-hide from Addresslist and Outlook/OWA                 - [ISSUE: Teams Groups invible in Outlook/OWA]
# (3) Add Owners as Members = make Visible in OWA for Owners   - [ISSUE: created in Admincenter disappear for owners]
$search = @(Get-UnifiedGroup -ResultSize unlimited) ;
$select = @($search | select name,displayname,primarySMTPaddress,SubscriptionEnabled,HiddenFromAddressListsEnabled,HiddenFromExchangeClientsEnabled) ;
$groups = @($select | Out-GridView -PassThru) ;
                   $SubscriDAGroup  = $groups | where { $_.SubscriptionEnabled -eq $false     }
foreach ($group in $SubscriDAGroup) { Set-UnifiedGroup $group.name -SubscriptionEnabled:$true ;
Write-host "Group [$($group.Name)] - [$($group.DisplayName)]  [subscription OFF ] >> Now [ENABLED] " -F green }
                   $GALHiddenGroup = $groups | where { $_.HiddenFromAddressListsEnabled -eq $true     }
foreach ($group in $GALHiddenGroup) { Set-UnifiedGroup $group.name -HiddenFromAddressListsEnabled:$false ;
Write-host "Group [$($group.Name)] - [$($group.DisplayName)]  [GAL HIDDEN] >> [GAL VISIBLE]" -F green }
                   $OLKHiddenGroup  = $groups | where { $_.HiddenFromExchangeClientsEnabled -eq $true }
foreach ($group in $OLKHiddenGroup) { Set-UnifiedGroup $group.name -HiddenFromExchangeClientsEnabled:$false ;
Write-host "Group [$($group.Name)] - [$($group.DisplayName)]  [OLK HIDDEN] >> [OLK VISIBLE]" -F green }
foreach ($group in $groups) {
    $members = Get-UnifiedGroupLinks -Identity $group.Name -LinkType Members; Write-host " Members $($members.count)" -F Magenta
     $Owners = Get-UnifiedGroupLinks -Identity $group.Name -LinkType Owners ; Write-host " Owners $($Owners.count)" -F Magenta
$subscr = Get-UnifiedGroupLinks -Identity $group.Name -LinkType Subscribers ;Write-host " subscribers $($subscr.count)`n" -F Green
foreach ($member in $members) { If ($member.Name -notin $subscr.Name) {
Add-UnifiedGroupLinks -Identity $group.Name -LinkType Subscribers -Links $member.Name
Write-host "Subscriber $($member.Name) added to [Group] $($group.Name) - [$($group.DisplayName)]" -F Green } }
Write-host "`nGroup $($group.Name) Adding Owners as Member`n (unhide from OWA Group List)" -F yellow
foreach ($Owner in $Owners) { 
If ($Owner.Name -notin $members.Name) { Add-UnifiedGroupLinks -Identity $group.Name -LinkType Members -Links $Owner.Name
    Write-host "[Owner]$($Owner.Name) added to [Group] $($group.Name) [$($group.DisplayName)] as [Member]" -F white}}}
