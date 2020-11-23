# Create Address Lists
New-AddressList -Name "Addresslist Internal ALL"  -RecipientFilter {(RecipientType -eq 'UserMailbox') -or (RecipientTypeDetails -eq 'SharedMailbox') -or (RecipientType -eq 'Mailuser')}
New-AddressList -Name "Addresslist NoCallQueue (internal)"  -RecipientFilter {((RecipientType -eq 'UserMailbox' -or RecipientTypeDetails -eq 'SharedMailbox' -or RecipientType -eq 'Mailuser') -and (CustomAttribute12 -notlike 'Helpdesk*'))}

#add FILTERED Addresslists
New-AddressList -Name "Addresslist Helpdesk1"  -RecipientFilter {((RecipientType -eq 'UserMailbox' -or RecipientTypeDetails -eq 'SharedMailbox' -or RecipientType -eq 'Mailuser') -and (CustomAttribute12 -eq 'Helpdesk1'))}
New-AddressList -Name "Addresslist Helpdesk2"  -RecipientFilter {((RecipientType -eq 'UserMailbox' -or RecipientTypeDetails -eq 'SharedMailbox' -or RecipientType -eq 'Mailuser') -and (CustomAttribute12 -eq 'Helpdesk2'))}
New-AddressList -Name "Addresslist Helpdesk3"  -RecipientFilter {((RecipientType -eq 'UserMailbox' -or RecipientTypeDetails -eq 'SharedMailbox' -or RecipientType -eq 'Mailuser') -and (CustomAttribute12 -eq 'Helpdesk3'))}

# common Addresslists
New-AddressList -Name "Addresslist External"  -RecipientFilter {(RecipientType -eq 'MailContact') }
New-AddressList -Name "Addresslist Groups" -RecipientFilter {(RecipientType -eq 'DynamicDistributionGroup') -or (RecipientType -eq 'MailUniversalDistributionGroup') -or (RecipientType -eq 'MailUniversalSecurityGroup')}
New-AddressList -Name "Room Lists"  -RecipientFilter {(RecipientTypeDetails -eq 'RoomList')}
New-AddressList -Name "Rooms" -RecipientFilter {(RecipientTypeDetails -eq 'RoomMailbox')}
New-AddressList -Name "Ressources" -RecipientFilter {(RecipientTypeDetails -eq 'EquipmentMailbox')}

# preview recipientfilter Helpdesk1
Get-Recipient -ResultSize unlimited -RecipientPreviewFilter {((RecipientType -eq 'UserMailbox' -or RecipientTypeDetails -eq 'SharedMailbox' -or RecipientType -eq 'Mailuser') -and (CustomAttribute12 -eq 'Helpdesk1'))}

# preview recipientfilter NoCallQueue
Get-Recipient -ResultSize unlimited -RecipientPreviewFilter {((RecipientType -eq 'UserMailbox' -or RecipientTypeDetails -eq 'SharedMailbox' -or RecipientType -eq 'Mailuser') -and (CustomAttribute12 -notlike 'Helpdesk*'))}

# Create Offline Address Book
New-OfflineAddressBook -Name "Offline Addressbook" -AddressLists "Addresslist Internal","Addresslist External","Addresslist Groups","Room Lists","Rooms","Ressources"

# Create Global Address Book INTERNAL only
New-GlobalAddressList  -Name "Global Adressbook Internal" -RecipientFilter "(RecipientType -eq 'UserMailbox') -or (RecipientType -eq 'Mailuser') -or (RecipientTypeDetails -eq 'SharedMailbox')"

# Create Address Book Policy

#Helpdesk 1,2,3 INCLUSIVE
New-AddressBookPolicy -Name "Adressbook Policy All” -AddressLists "Addresslist Internal ALL","Addresslist NoCallQueue (internal)","Addresslist Helpdesk1","Addresslist Helpdesk2","Addresslist Helpdesk3","Addresslist External","Addresslist Groups","Room Lists","Rooms","Ressources" -RoomList "\Room Lists" -OfflineAddressBook “\Offline Addressbook” -GlobalAddressList “\Global Adressbook Internal”

#Helpdesk 1 EXCLUSIVE
New-AddressBookPolicy -Name "Adressbook Policy Helpdesk1” -AddressLists "Addresslist Internal ALL","Addresslist NoCallQueue (internal)","Addresslist Helpdesk1","Addresslist External","Addresslist Groups","Room Lists","Rooms","Ressources" -RoomList "\Room Lists" -OfflineAddressBook “\Offline Addressbook” -GlobalAddressList “\Global Adressbook Internal”

#Helpdesk 2 EXCLUSIVE
New-AddressBookPolicy -Name "Adressbook Policy Helpdesk2” -AddressLists "Addresslist Internal ALL","Addresslist NoCallQueue (internal)","Addresslist Helpdesk2","Addresslist External","Addresslist Groups","Room Lists","Rooms","Ressources" -RoomList "\Room Lists" -OfflineAddressBook “\Offline Addressbook” -GlobalAddressList “\Global Adressbook Internal”

#Helpdesk 3 EXCLUSIVE
New-AddressBookPolicy -Name "Adressbook Policy Helpdesk3” -AddressLists "Addresslist Internal ALL","Addresslist NoCallQueue (internal)","Addresslist Helpdesk3","Addresslist External","Addresslist Groups","Room Lists","Rooms","Ressources" -RoomList "\Room Lists" -OfflineAddressBook “\Offline Addressbook” -GlobalAddressList “\Global Adressbook Internal”

get-AddressBookPolicy
#check wih test user first
Get-Mailbox TESTUSER | Set-Mailbox -AddressBookPolicy "Adressbook Policy”

# later assign to all users if it is confirmed to be running
Get-Mailbox -ResultSize unlimited -Filter {(RecipientType -eq 'UserMailbox')} | Set-Mailbox -AddressBookPolicy "Adressbook Policy”

#FILTER + ASSIGN EXCLUSIVE to Mailboxes by Customattribute
Get-Mailbox -ResultSize unlimited -Filter {(RecipientType -eq 'UserMailbox') -and (CustomAttribute12 -eq 'Helpdesk1')} | Set-Mailbox -AddressBookPolicy "Adressbook Policy Helpdesk1”

Get-Mailbox -ResultSize unlimited -Filter {(RecipientType -eq 'UserMailbox') -and (CustomAttribute12 -eq 'Helpdesk2')} | Set-Mailbox -AddressBookPolicy "Adressbook Policy Helpdesk2”

Get-Mailbox -ResultSize unlimited -Filter {(RecipientType -eq 'UserMailbox') -and (CustomAttribute12 -eq 'Helpdesk3')} | Set-Mailbox -AddressBookPolicy "Adressbook Policy Helpdesk3”

# Inclusive where no Customattribute is set
Get-Mailbox -ResultSize unlimited -Filter {((RecipientType -eq 'UserMailbox' -or RecipientTypeDetails -eq 'SharedMailbox' -or RecipientType -eq 'Mailuser') -and (CustomAttribute12 -notlike 'Helpdesk*'))} | Set-Mailbox -AddressBookPolicy "Adressbook Policy All”

AddressBookPolicy grouped list

Get-mailbox -ResultSize unlimited | group AddressBookPolicy

# update Addresslists

get-AddressList | % { Set-AddressList -Identity $_.identity }