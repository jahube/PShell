###########################################################################################

install-module Exchangeonlinemanagement

###########################################################################################

$ADMIN = "admin@domain.com"                                     # Change please

$credential = get-credential $ADMIN                             # run + enter password

connect-Exchangeonline -credential $credential                  # connect

New-ManagementRoleAssignment -Role "Address Lists" -User $ADMIN # permission

connect-Exchangeonline -credential $credential                  # connect AGAIN ! IMPORTANT

###########################################################################################

       # ENGLISH

       $intern_AL = "Addresslist (internal)"
       $extern_AL = "Addresslist Contacts (external)"
       $Groups_AL = "Addresslist Groups"
     $RoomList_AL = "Roomlists"
        $Rooms_AL = "Rooms"
   $Ressources_AL = "Ressources"
$RessourcesALL_AL = "All Ressources"
     $Offline_GAL = “Offline Addressbook”
     $default_GAL = “Global Adressbook”
$AdressbookPolicy = "Adressbook Policy”

        # GERMAN

       $intern_AL = "Addressliste (intern)"
       $extern_AL = "Addressliste - Kontakte (extern)"
       $Groups_AL = "Addressliste Gruppen"
     $RoomList_AL = "Raumliste"
        $Rooms_AL = "Räume"
   $Ressources_AL = "Ausrüstung"
$RessourcesALL_AL = "Alle Ressourcen"
     $Offline_GAL = “Offline Addressbuch”
     $default_GAL = “Globales Addressbuch”
$AdressbookPolicy = "Adressbook Policy”

# Create Address Lists
New-AddressList -Name $intern_AL  -RecipientFilter {(RecipientType -eq 'UserMailbox') -or (RecipientTypeDetails -eq 'SharedMailbox') -or (RecipientType -eq 'Mailuser')}
New-AddressList -Name $extern_AL  -RecipientFilter {(RecipientType -eq 'MailContact') }
New-AddressList -Name $Groups_AL -RecipientFilter {(RecipientType -eq 'DynamicDistributionGroup') -or (RecipientType -eq 'MailUniversalDistributionGroup') -or (RecipientType -eq 'MailUniversalSecurityGroup')}
New-AddressList -Name $RoomList_AL  -RecipientFilter {(RecipientTypeDetails -eq 'RoomList')}
New-AddressList -Name $Rooms_AL -RecipientFilter {(RecipientTypeDetails -eq 'RoomMailbox')}
New-AddressList -Name $Ressources_AL -RecipientFilter {(RecipientTypeDetails -eq 'EquipmentMailbox')}
New-AddressList -Name $RessourcesALL_AL -RecipientFilter {(RecipientTypeDetails -eq 'EquipmentMailbox') -or (RecipientTypeDetails -eq 'RoomMailbox')}

# Create Offline Address Book
New-OfflineAddressBook -Name $Offline_GAL -AddressLists $intern_AL,$extern_AL,$Groups_AL,$RoomList_AL,$Rooms_AL,$Ressources_AL,$RessourcesALL_AL

# Create Global Address Book INTERNAL only
New-GlobalAddressList  -Name $default_GAL -RecipientFilter "(RecipientType -eq 'UserMailbox') -or (RecipientType -eq 'Mailuser') -or (RecipientTypeDetails -eq 'SharedMailbox')"

# Create Address Book Policy
New-AddressBookPolicy -Name $AdressbookPolicy -AddressLists $intern_AL,$extern_AL,$Groups_AL,$RoomList_AL,$Rooms_AL,$Ressources_AL,$RessourcesALL_AL -RoomList "\$RoomList_AL" -OfflineAddressBook “\$Offline_GAL” -GlobalAddressList “\$default_GAL”

#check wih test user first
Get-Mailbox TESTUSER | Set-Mailbox -AddressBookPolicy $AdressbookPolicy

# later assign to all users if it is confirmed to be running
Get-Mailbox -Filter {(RecipientType -eq 'UserMailbox')} | Set-Mailbox -AddressBookPolicy $AdressbookPolicy

# update Addresslists
get-AddressList | % { Set-AddressList -Identity $_.identity }