﻿###########################################################################################

install-module Exchangeonlinemanagement

###########################################################################################
$ADMIN = "admin@domain.com"                                     # Change please

$credential = get-credential $ADMIN                             # run + enter password

connect-Exchangeonline -credential $credential                  # connect

New-ManagementRoleAssignment -Role "Address List" -User $ADMIN  # permission

connect-Exchangeonline -credential $credential                  # connect AGAIN ! IMPORTANT

###########################################################################################

# Create Address Lists
New-AddressList -Name "Addresslist Internal"  -RecipientFilter {(RecipientType -eq 'UserMailbox') -or (RecipientTypeDetails -eq 'SharedMailbox') -or (RecipientType -eq 'Mailuser')}
New-AddressList -Name "Addresslist External"  -RecipientFilter {(RecipientType -eq 'MailContact') }
New-AddressList -Name "Addresslist Groups" -RecipientFilter {(RecipientType -eq 'DynamicDistributionGroup') -or (RecipientType -eq 'MailUniversalDistributionGroup') -or (RecipientType -eq 'MailUniversalSecurityGroup')}
New-AddressList -Name "Room Lists"  -RecipientFilter {(RecipientTypeDetails -eq 'RoomList')}
New-AddressList -Name "Rooms" -RecipientFilter {(RecipientTypeDetails -eq 'RoomMailbox')}
New-AddressList -Name "Ressources" -RecipientFilter {(RecipientTypeDetails -eq 'EquipmentMailbox')}

# Create Offline Address Book
New-OfflineAddressBook -Name "Offline Addressbook" -AddressLists "Addresslist Internal","Addresslist External","Addresslist Groups","Room Lists","Rooms","Ressources"

# Create Global Address Book INTERNAL only
New-GlobalAddressList  -Name "Global Adressbook Internal" -RecipientFilter "(RecipientType -eq 'UserMailbox') -or (RecipientType -eq 'Mailuser') -or (RecipientTypeDetails -eq 'SharedMailbox')"

# Create Address Book Policy
New-AddressBookPolicy -Name "Adressbook Policy” -AddressLists "Addresslist Internal","Addresslist External","Addresslist Groups","Room Lists","Rooms","Ressources" -RoomList "\Room Lists" -OfflineAddressBook “\Offline Addressbook” -GlobalAddressList “\Global Adressbook Internal”

#check wih test user first
Get-Mailbox TESTUSER | Set-Mailbox -AddressBookPolicy "Adressbook Policy”

# later assign to all users if it is confirmed to be running
Get-Mailbox -Filter {(RecipientType -eq 'UserMailbox')} | Set-Mailbox -AddressBookPolicy "Adressbook Policy”

# update Addresslists
get-AddressList | % { Set-AddressList -Identity $_.identity }
