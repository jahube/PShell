# (1) Follow Group in Inbox + enable Subscription              - [ISSUE: Emails only in Group Mailbox + (2) = "don't get emails"]

# (2) Un-hide from Addresslist and Outlook/OWA                 - [ISSUE: Teams Groups invible in Outlook/OWA]

# (3) Add Owners as Members = make Visible in OWA for Owners   - [ISSUE: created in Admincenter disappear for owners]

#  Documentation ADD Office 365 Group Subscribers   
#              https://support.microsoft.com/en-us/office/follow-a-group-in-outlook-e147fc19-f548-4cd2-834f-80c6235b7c36
#  inspired by https://www.knowledgebase.it/powershell/install-azure-active-directory-in-powershell/fixoffice365groupsubscriptions/

# check groups to know the valid Group data

Get-UnifiedGroup | FT name,displayname,primarySMTPaddress,ExternalDirectoryObjectId,HiddenFromAddressListsEnabled,HiddenFromExchangeClientsEnabled

# (1) ALL GROUPS

$groups = Get-UnifiedGroup -ResultSize unlimited

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

if (!($group.SubscriptionEnabled)) {

              Set-UnifiedGroup $group.name -SubscriptionEnabled:$true ;

                    Write-host "Group [$($group.Name)] - [$($group.DisplayName)]" -F yellow -N ;
                    Write-host " [subscription OFF]" -F white -N
                    Write-host "  - Now [ENABLED] successfully `n( waiting 5 seconds replication time ) " -F green ;
              Start-Sleep 5   }
       else {       Write-host "Group [$($group.Name)] - [$($group.DisplayName)]" -F cyan  -NoNewline ; 
                    Write-host " [subscription ENABLED]" -F green  }

  if ($group.HiddenFromAddressListsEnabled) {

              Set-UnifiedGroup $group.name -HiddenFromAddressListsEnabled:$false ;

                    Write-host "Group [$($group.Alias)] - [$($group.DisplayName)]" -F yellow -N ;
                    Write-host " [HiddenFromAddressLists ENABLED]" -F white -N
                    Write-host "  - Now [OFF] successfully " -F green }

       else {       Write-host "Group [$($group.Name)] - [$($group.DisplayName)]"  -F cyan  -N ; 
                    Write-host " [HiddenFromAddressLists OFF]" -F green }

  if ($group.HiddenFromExchangeClientsEnabled) {

              Set-UnifiedGroup $group.name -HiddenFromExchangeClientsEnabled:$false ;

                    Write-host "Group [$($group.Name)] - [$($group.DisplayName)]"  -F yellow  -N ;
                    Write-host " [HiddenFromExchangeClientsEnabled ENABLED]" -F white -NoNewline
                    Write-host "  - Now [OFF] successfully " -F green ;
                                               } 
       else {       Write-host "Group [$($group.Name)] - [$($group.DisplayName)]"  -F cyan  -NoNewline ; 
                    Write-host " [HiddenFromExchangeClientsEnabled OFF]" -F green }

$members = Get-UnifiedGroupLinks -Identity $group.Name -LinkType Members

                    Write-host " Members $($members.count)" -F Magenta

$Owners = Get-UnifiedGroupLinks -Identity $group.Name -LinkType Owners

                    Write-host " Owners $($Owners.count)" -F Magenta

$subscribers = Get-UnifiedGroupLinks -Identity $group.Name -LinkType Subscribers

                    Write-host " subscribers $($subscribers.count)1`n" -F Green

foreach ($member in $members) { 

If ($member.Name -notin $subscribers.Name) {

         Add-UnifiedGroupLinks -Identity $group.Name -LinkType Subscribers -Links $member.Name

                    Write-host "Subscriber " -F white -NoNewline
                    Write-host "$($member.Name)" -F yellow -NoNewline
                    Write-host " added to " -F Green -NoNewline
                    Write-host "[Group] $($group.Name) - [$($group.DisplayName)]" -F white 
                                           }
      else {        Write-host "subscriber " -F white -NoNewline
                    Write-host "$($member.Name)" -F green -NoNewline
                    Write-host " already follower of " -F yellow -NoNewline
                    Write-host "[Group] $($group.Name)  - [$($group.DisplayName)]" -F white } 
                                   }

                    Write-host "`nGroup $($group.Name) Adding Owners as Member`n (unhide from OWA Group List)" -F yellow

foreach ($Owner in $Owners) { 

If ($Owner.Name -notin $members.Name) {

         Add-UnifiedGroupLinks -Identity $group.Name -LinkType Members -Links $Owner.Name

                    Write-host "[Owner] " -F white -NoNewline
                    Write-host "$($Owner.Name)" -F yellow -NoNewline
                    Write-host " added to " -F Green -NoNewline
                    Write-host "[Group] $($group.Name) - [$($group.DisplayName)] as [Member]" -F white 
                                      } 

      else {        Write-host "[Owner] " -F white -NoNewline
                    Write-host "$($Owner.Name)" -F green -NoNewline
                    Write-host " already Member of [Group] - [$($group.DisplayName)]" -F yellow -NoNewline
                    Write-host "$($group.Name)" -F white 
                                      } 
                             } 
                    } 
      # End #       
