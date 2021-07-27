###########################################################################################

install-module Exchangeonlinemanagement

###########################################################################################

$ADMIN = "admin@domain.com"                                     # Change please

$credential = get-credential $ADMIN                             # run + enter password

connect-Exchangeonline -credential $credential                  # connect

New-ManagementRoleAssignment -Role "Address Lists" -User $ADMIN # permission

connect-Exchangeonline -credential $credential                  # connect AGAIN ! IMPORTANT

###########################################################################################

       # IMPORTANT

ONLY the "Managers" will see objects which have 

CustomAttribute11 -eq "Manager"
         
------------------------------------------------------------------

          # ENGLISH

        $Managers = "Manager" # change the value here
      
       $intern_AL = "Addresslist (internal)  $Managers"
       $extern_AL = "Addresslist Contacts (external)  $Managers"
       $Groups_AL = "Addresslist Groups  $Managers"
     $RoomList_AL = "Roomlists  $Managers"
        $Rooms_AL = "Rooms  $Managers"
   $Ressources_AL = "Ressources  $Managers"
     $Offline_GAL = “Offline Addressbook  $Managers”
     $default_GAL = “Global Adressbook  $Managers”
$AdressbookPolicy = "Adressbook Policy  $Managers”

------------------------------------------------------------------

        # GERMAN
        $Managers = "Manager" # change the value here
      
       $intern_AL = "Addressliste (intern) $Managers"
       $extern_AL = "Addressliste - Kontakte (extern) $Managers"
       $Groups_AL = "Addressliste Gruppen $Managers"
     $RoomList_AL = "Raumliste $Managers"
        $Rooms_AL = "Räume $Managers"
   $Ressources_AL = "Ausrüstung $Managers"
     $Offline_GAL = “Offline Addressbuch $Managers”
     $default_GAL = “Globales Addressbuch $Managers”
$AdressbookPolicy = "Adressbuchrichtlinie $Managers”

------------------------------------------------------------------

# Create Address Lists             # CHECK AT THE below 4 lines and change "Manager" at end of line if necessary

New-AddressList -Name $intern_AL  -RecipientFilter {(RecipientType -eq 'UserMailbox') -or (RecipientTypeDetails -eq 'SharedMailbox') -or (RecipientType -eq 'Mailuser')}
New-AddressList -Name $extern_AL  -RecipientFilter {(RecipientType -eq 'MailContact') -and (CustomAttribute15 -eq "Manager")}
New-AddressList -Name $Groups_AL -RecipientFilter {(RecipientType -eq 'DynamicDistributionGroup') -or (RecipientType -eq 'MailUniversalDistributionGroup') -or (RecipientType -eq 'MailUniversalSecurityGroup')}
New-AddressList -Name $RoomList_AL  -RecipientFilter {(RecipientTypeDetails -eq 'RoomList') -and (CustomAttribute15 -eq "Manager")}

# Create Offline Address Book
New-OfflineAddressBook -Name $Offline_GAL -AddressLists $intern_AL,$extern_AL,$Groups_AL,$RoomList_AL,$Rooms_AL,$Ressources_AL

# Create Global Address Book INTERNAL only
New-GlobalAddressList  -Name $default_GAL -RecipientFilter "((RecipientType -eq 'UserMailbox') -or (RecipientType -eq 'Mailuser') -or (RecipientTypeDetails -eq 'SharedMailbox'))"

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

$Office = "Management Büro"

Get-Mailbox -Filter {(RecipientType -eq 'UserMailbox')} -resultsize unlimited |  ? {$_.Office -eq $Office } | Set-Mailbox -AddressBookPolicy $AdressbookPolicy

---------------------------------------

# Filter Mailboxes by Manager

$MANAGER = (Get-Recipient "CEO@Email.here").Distinguishedname

Get-Mailbox -Filter {(RecipientType -eq "UserMailbox") -AND "Manager -eq $MANAGER"} -resultsize unlimited  | Set-Mailbox -AddressBookPolicy $AdressbookPolicy


# update Addresslists

get-AddressList | % { Set-AddressList -Identity $_.identity }