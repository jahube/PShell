$company = 'Contoso'

#$company = 'Fabrikam'
# keep in mind that the external users might not have company attribute
# -and (Company -eq $company)

# Create Address Lists
New-AddressList -Name "Addresslist Internal $company"  -RecipientFilter {((RecipientType -eq 'UserMailbox') -or (RecipientTypeDetails -eq 'SharedMailbox') -or (RecipientType -eq 'Mailuser')) -and (Company -eq $company)}
New-AddressList -Name "Addresslist External $company"  -RecipientFilter {(RecipientType -eq 'MailContact') -and (Company -eq $company)}
New-AddressList -Name "Addresslist Groups $company" -RecipientFilter {((RecipientType -eq 'DynamicDistributionGroup') -or (RecipientType -eq 'MailUniversalDistributionGroup') -or (RecipientType -eq 'MailUniversalSecurityGroup')) -and (Company -eq $company)}
New-AddressList -Name "Room Lists $company"  -RecipientFilter {(RecipientTypeDetails -eq 'RoomList') -and (Company -eq $company)}
New-AddressList -Name "Rooms $company" -RecipientFilter {(RecipientTypeDetails -eq 'RoomMailbox') -and (Company -eq $company)}
New-AddressList -Name "Ressources $company" -RecipientFilter {(RecipientTypeDetails -eq 'EquipmentMailbox') -and (Company -eq $company)}

# Create Offline Address Book
New-OfflineAddressBook -Name "Offline Addressbook $company" -AddressLists "Addresslist Internal $company","Addresslist External $company","Addresslist Groups $company","Room Lists $company","Rooms $company","Ressources $company"

# Create Global Address Book INTERNAL only
New-GlobalAddressList  -Name "Global Adressbook Internal $company" -RecipientFilter { ((RecipientType -eq 'UserMailbox') -or (RecipientType -eq 'Mailuser') -or (RecipientTypeDetails -eq 'SharedMailbox')) -and (Company -eq $company)}

# Create Address Book Policy
New-AddressBookPolicy -Name "Adressbook Policy $company” -AddressLists "Addresslist Internal $company","Addresslist External $company","Addresslist Groups $company","Room Lists $company","Rooms $company","Ressources $company" -RoomList "\Room Lists $company" -OfflineAddressBook “\Offline Addressbook $company” -GlobalAddressList “\Global Adressbook Internal $company”

#check wih test user first
Get-Mailbox TESTUSER | Set-Mailbox -AddressBookPolicy "Adressbook Policy $company”

# later assign to all users if it is confirmed to be running
Get-Mailbox -Filter {(RecipientType -eq 'UserMailbox') -and (Company -eq $company)} | Set-Mailbox -AddressBookPolicy "Adressbook Policy $company”

# update Addresslists
get-AddressList | % { Set-AddressList -Identity $_.identity }


######### connect #########################################################################

install-module Exchangeonlinemanagement

###########################################################################################

$ADMIN = "admin@domain.com"                                     # Change please

$credential = get-credential $ADMIN                             # run + enter password

connect-Exchangeonline -credential $credential                  # connect

New-ManagementRoleAssignment -Role "Address Lists" -User $ADMIN # permission

connect-Exchangeonline -credential $credential                  # connect AGAIN ! IMPORTANT

###########################################################################################