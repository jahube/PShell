###########################################################################################

install-module Exchangeonlinemanagement

###########################################################################################

$ADMIN = "admin@domain.com"                                     # Change please

$credential = get-credential $ADMIN                             # run + enter password

connect-Exchangeonline -credential $credential                  # connect

New-ManagementRoleAssignment -Role "Address Lists" -User $ADMIN # permission

connect-Exchangeonline -credential $credential                  # connect AGAIN ! IMPORTANT

###########################################################################################

              # English

       $intern_AL = "Addresslist (internal)"
       $extern_AL = "Addresslist Contacts (external)"
       $Groups_AL = "Addresslist Groups"
     $RoomList_AL = "Roomlists"
        $Rooms_AL = "Rooms"
   $Ressources_AL = "Ressources"
     $Offline_GAL = “Offline Addressbook”
     $default_GAL = “Global Adressbook”
$AdressbookPolicy = "Adressbook Policy”

              # German

       $intern_AL = "Addressliste (intern)"
       $extern_AL = "Addressliste - Kontakte (extern)"
       $Groups_AL = "Addressliste Gruppen"
     $RoomList_AL = "Raumliste"
        $Rooms_AL = "Räume"
   $Ressources_AL = "Ausrüstung"
     $Offline_GAL = “Offline Addressbuch”
     $default_GAL = “Globales Addressbuch”
$AdressbookPolicy = "Adressbuchrichtlinie”


CustomAttribute11 -ne "ManagersOnly" = "invisible" for this Adressbook Policy

# Create Address Lists             # CHECK AT THE below 4 lines and change "Manager" at end of line if necessary

New-AddressList -Name $intern_AL  -RecipientFilter {(RecipientType -eq 'UserMailbox') -or (RecipientTypeDetails -eq 'SharedMailbox') -or (RecipientType -eq 'Mailuser') -and (CustomAttribute15 -ne "ManagersOnly")}
New-AddressList -Name $extern_AL  -RecipientFilter {(RecipientType -eq 'MailContact') -and (CustomAttribute15 -ne "ManagersOnly")}
New-AddressList -Name $Groups_AL -RecipientFilter {(RecipientType -eq 'DynamicDistributionGroup') -or (RecipientType -eq 'MailUniversalDistributionGroup') -or (RecipientType -eq 'MailUniversalSecurityGroup') -and (CustomAttribute15 -ne "ManagersOnly")}
New-AddressList -Name $RoomList_AL  -RecipientFilter {(RecipientTypeDetails -eq 'RoomList') -and (CustomAttribute15 -ne "ManagersOnly")}

# Create Offline Address Book
New-OfflineAddressBook -Name $Offline_GAL -AddressLists $intern_AL,$extern_AL,$Groups_AL,$RoomList_AL,$Rooms_AL,$Ressources_AL

# Create Global Address Book INTERNAL only
New-GlobalAddressList  -Name $default_GAL -RecipientFilter "((RecipientType -eq 'UserMailbox') -or (RecipientType -eq 'Mailuser') -or (RecipientTypeDetails -eq 'SharedMailbox')) -and (CustomAttribute15 -ne "ManagersOnly")"

# Create Address Book Policy
New-AddressBookPolicy -Name $AdressbookPolicy -AddressLists $intern_AL,$extern_AL,$Groups_AL,$RoomList_AL -RoomList "\$RoomList_AL" -OfflineAddressBook “\$Offline_GAL” -GlobalAddressList “\$default_GAL”


# tag Objects to be visible for "Manager"

          set-mailbox USERNAME -CustomAttribute15 "ManagersOnly"

Set-DistributionGroup USERNAME -CustomAttribute15 "ManagersOnly"

     Set-UnifiedGroup USERNAME -CustomAttribute15 "ManagersOnly"

         Set-MailUser USERNAME -CustomAttribute15 "ManagersOnly"

      Set-MailContact USERNAME -CustomAttribute15 "ManagersOnly"

# check wih test user 

Get-Mailbox USER@NAME | Set-Mailbox -AddressBookPolicy $AdressbookPolicy

# later assign to all users if it is confirmed to be running

---------------------------------------

# Filter Mailboxes by Office

$Office = "Büro"

Get-Mailbox -Filter {(RecipientType -eq 'UserMailbox')} -resultsize unlimited |  ? {$_.Office -eq $Office } | Set-Mailbox -AddressBookPolicy $AdressbookPolicy

---------------------------------------

# Filter Mailboxes by Manager

$MANAGER = (Get-Recipient "Manager@Email.here").Distinguishedname

Get-Mailbox -Filter {(RecipientType -eq "UserMailbox") -AND "Manager -eq $MANAGER"} -resultsize unlimited  | Set-Mailbox -AddressBookPolicy $AdressbookPolicy


# update Addresslists

get-AddressList | % { Set-AddressList -Identity $_.identity }