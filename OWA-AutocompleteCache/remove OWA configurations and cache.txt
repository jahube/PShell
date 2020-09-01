# remove ALL users OWA configurations
get-mailbox | select userprincipalname | % { Remove-MailboxUserConfiguration -Mailbox $_.userprincipalname -Identity Configuration\IPM.Configuration.Aggregated.OwaUserConfiguration -Confirm:$false }

################
# for one user #
################
$user = "user@domain.com"

# get $user OWA configurations
$OWAconfig = Get-MailboxUserConfiguration -Mailbox $user -Identity Configuration\IPM.Configuration.Aggregated.OwaUserConfiguration
# list $user OWA configurations
$OWAconfig[-1]

# get $user MBX configurations
$MBXconfig = Get-MailboxUserConfiguration -Mailbox $user -Identity Configuration\*

# list $user MBX configurations
$MBXconfig.ConfigurationName[-1]

$user = "user@domain.com"
Set-MailboxMessageConfiguration -Identity $user -SendAddressDefault $user

# remove $user OWA configurations
Remove-MailboxUserConfiguration -Mailbox $user -Identity Configuration\IPM.Configuration.Aggregated.OwaUserConfiguration

# remove $user AUTOCOMPLETE CACHE
$user = "user@domain.com"
Remove-MailboxUserConfiguration -Mailbox $user -Identity Configuration\IPM.Configuration.OWA.AutocompleteCache

# remove $user MAILBOX configurations
$user = "user@domain.com"
Get-MailboxUserConfiguration -Mailbox $user -Identity Configuration\* | Remove-MailboxUserConfiguration -Mailbox $user -Confirm:$false

#####################
# for all mailboxes #
#####################

# remove ALL users OWA configurations
get-mailbox | select userprincipalname | % { Remove-MailboxUserConfiguration -Mailbox $_.userprincipalname -Identity Configuration\IPM.Configuration.Aggregated.OwaUserConfiguration -Confirm:$false }


# remove ALL users MAILBOX configurations
get-mailbox | select userprincipalname | % { Get-MailboxUserConfiguration -Mailbox $_.userprincipalname -Identity Configuration\* | Remove-MailboxUserConfiguration -Mailbox $_.userprincipalname -Confirm:$false }


# remove ALL users AUTOCOMPLETE CACHE
get-mailbox -resultsize unlimited | % { Remove-MailboxUserConfiguration -Mailbox $_.userprincipalname -Identity Configuration\IPM.Configuration.OWA.AutocompleteCache -Confirm:$false }


# list ALL users MAILBOX configurations
get-mailbox | select userprincipalname | % { Get-MailboxUserConfiguration -Mailbox $_.userprincipalname -Identity Configuration\* | fl MailboxOwnerId, ConfigurationName }


Set-MailboxMessageConfiguration -SendAddressDefault

##############################################################################
# below was tested only to ensure production mailboxes settings not affected #
##############################################################################

# set first time popup screen - tested, but not affected

#get
get-MailboxMessageConfiguration -Identity $user | fl ShowReadingPaneOnFirstLoad

#set
Set-MailboxMessageConfiguration -Identity $user -ShowReadingPaneOnFirstLoad $false

# Set Owa language - tested, but not affected

#get
Get-MailboxRegionalConfiguration -Identity $user | fl 

################
# for one user #
################
$user = "user@domain.com"

#set
$Lang = "DE-DE"
$Time = "HH:mm"
$DateFormat = "dd.MM.yyyy"
Set-MailboxRegionalConfiguration -Identity $user -Language $Lang -TimeFormat $Time -DateFormat $DateFormat -LocalizeDefaultFolderName:$true

#####################
# for all mailboxes #
#####################

#set lang for all users
$Lang = "DE-DE"
$Time = "HH:mm"
$DateFormat = "dd.MM.yyyy"
$TimeZone = "W. Europe Standard Time" 

$users = get-mailbox -resultsize unlimited
$foreach ($user in $users) { try {Set-MailboxRegionalConfiguration -Identity $user.userprincipalname -Language $Lang -TimeZone $TimeZone -TimeFormat $Time -DateFormat $DateFormat -LocalizeDefaultFolderName:$true -Confirm:$false}{ Write-host $error[0]}}

# OR slower
 
get-mailbox | select userprincipalname | % { Set-MailboxRegionalConfiguration -Identity $_.userprincipalname -Language $Lang -TimeFormat $Time -TimeZone $TimeZone -DateFormat $DateFormat -LocalizeDefaultFolderName:$true -Confirm:$false }


get-mailbox | select userprincipalname | Get-User -Filter "c -eq 'DE'"| % { Set-MailboxRegionalConfiguration -Identity $_.userprincipalname -Language $Lang -TimeFormat $Time -DateFormat $DateFormat -LocalizeDefaultFolderName:$true -Confirm:$false }

Get-User -Filter "c -eq 'DE'"

get-mailbox | where {country eq=DE} |

Set-Mailbox -UseDatabaseQuotaDefaults:$false


references autocomplete cache

https://gallery.technet.microsoft.com/office/Clearing-AutoComplete-and-92b8d32a/view/Discussions

# https://www.enowsoftware.com/solutions-engine/bid/184025/clearing-autocomplete-and-other-recipient-caches
# https://support.office.com/en-us/article/import-or-copy-the-auto-complete-list-to-another-computer-83558574-20dc-4c94-a531-25a42ec8e8f0
# https://support.microsoft.com/en-us/help/2199226/information-about-the-outlook-autocomplete-list
# https://www.msoutlook.info/question/backup-and-restore-autocomplete



$users = get-mailbox -resultsize unlimited
$foreach ($user in $users) { try {Set-MailboxRegionalConfiguration -Identity $user.userprincipalname -WeekStartDay Sunday -WorkDays 5 -Confirm:$false} catch { Write-host $error[0]}}


$mbxs = get-mailbox -ResultSize unlimited
$count = $mbxs.count ; $i=0
$c = 'Configuration\IPM.Configuration.OWA.AutocompleteCache'
foreach ($mbx in $mbxs.userprincipalname) { $i++; Try { 
Remove-MailboxUserConfiguration -Mailbox $mbx -Identity $c -Confirm:$false 
} catch { Write-Host $Error[0] }
Write-Progress -Activity "Clearing OWA Autocomplete Cache." -Id 2 `
-ParentId 1 -Status "Mailbox: $mbx" -PercentComplete (($i/$count)*100)}
