
######################################################
# classic - custom retention tag for calendar folder #
######################################################

https://docs.microsoft.com/en-us/exchange/security-and-compliance/messaging-records-management/default-folders

##################
# install EXO PS #
##################

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Set-ExecutionPolicy RemoteSigned

Install-Module -Name ExchangeOnlineManagement

##################
# connect EXO PS #
##################

$ADMIN = "global@Admin.com"

Connect-ExchangeOnline -UserPrincipalName $ADMIN

#################
# collect users #
#################

#for all
$users = Get-Mailbox -resultsize unlimited

#1 O365 Groupmembers only
$users = Get-UnifiedGroupLinks -Identity "Group name" -LinkType Members -resultsize unlimited

#2 members of an office
$users = Get-Mailbox -resultsize unlimited | where { $_.office -match "Officename" }

#3 ALL Mailboxes 
$users = Get-Mailbox -resultsize unlimited

#4 manual list
$users = "user1@domain.com", "user2@domain.com", "user3@domain.com", "user4@domain.com"

#########################
# Remove-CalendarEvents #
#########################

# Timefrage in DAYS / Max. is 1825 = 5 years
$timeframe = "1825" 

# Startdate for Search in Years
$Start = (get-date).AddYears(-6) # keeps last year and deletes 5 before
$Start = (get-date).AddYears(-5) # deletes last 5
$mcount = 1
$Mbxcount = $users.count
Foreach ($user in $users) {
Write-Progress -Activity "deleting calendar items - current mailbox [ $($mcount)/$($Mbxcount) ]" -Id 2 -ParentId 1 -Status "Mailbox: $($user.userprincipalname)" -PercentComplete (($mcount/$Mbxcount)*100)
try { Remove-CalendarEvents -identity $user.Distinguishedname -CancelOrganizedMeetings -QueryStartDate $Start -QueryWindowInDays $timeframe -Confirm:$false } catch { Write-host $error[0] }
$mcount++
}

#################################
# Second Option: Search-Mailbox #
#################################

#assign  permissions (Search-Mailbox / "Mailbox Search")
New-ManagementRoleAssignment -Role "Mailbox Search" -User $ADMIN
#reconnect
get-pssession | remove-pssession ; Connect-ExchangeOnline -UserPrincipalName $ADMIN

# SEARCHmailbox (lots of progress-bars)
Foreach ($user in $users) { 
try { Search-Mailbox -identity $user.DistinguishedName -SearchQuery kind:meetings -DeleteContent -Confirm:$false -force } catch { Write-host $error[0] }
}


###################################################
# Third Option: ComplianceSearch Purge HardDelete #
###################################################

$USER = "affecteduser@DOMAIN.com"

$searchname= "NEW SEARCH NAME"

$USER = "ADMIN@DOMAINcom"

Connect-ExchangeOnline -userprincipalname $admin"

$ID= (get-mailboxfolderstatistics -identity $USER -folderscope calendar).folderid

Connect-IPPSSession -userprincipalname $admin

New-ComplianceSearch -Name $searchname -ExchangeLocation $USER -ContentMatchQuery "FolderID:$ID"

Start-ComplianceSearch -Identity $searchname

get-ComplianceSearch -Identity $searchname

New-ComplianceSearchAction -SearchName $searchname -Purge -PurgeType HardDelete

#################
# recover items #
#################

#assign  permissions (recoverableitems / "Mailbox Import Export" )
New-ManagementRoleAssignment -Role "Mailbox Import Export" -User $ADMIN
#reconnect
get-pssession | remove-pssession ; Connect-ExchangeOnline -UserPrincipalName $ADMIN

# restore 
$mcount = 1
$Mbxcount = $users.count
Foreach ($user in $users) { 
Write-Progress -Activity "restore calendar items - current mailbox [ $($mcount)/$($Mbxcount) ]" -Id 2 -ParentId 1 -Status "Mailbox: $($user.userprincipalname)" -PercentComplete (($mcount/$Mbxcount)*100)
get-recoverableitems $user.distinguishedname -FilterItemType IPM.Appointment | restore-recoverableitems
$mcount++
}

######## End ############

Get-MailboxFolderStatistics - identity $user -FolderScope -FolderScope Calendar