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

# the users then will ONLY see 
# Mailboxes contact groups rooms which have 
# CustomAttribute11 -eq "Custom_INCLUDE_Value"
         
# change here to a custom value that appears for the users with a LIMITED GAL
# The TAG is the Extension these users will see

# for Example "Roomlists Team" - the word Team was added as a Suffix to avoid conflict

          # ENGLISH

        $TeamName = "Team" # 
      
       $intern_AL = "Addresslist (internal)  $TeamName"
       $extern_AL = "Addresslist Contacts (external)  $TeamName"
       $Groups_AL = "Addresslist Groups  $TeamName"
     $RoomList_AL = "Roomlists  $TeamName"
        $Rooms_AL = "Rooms  $TeamName"
   $Ressources_AL = "Ressources  $TeamName"
     $Offline_GAL = “Offline Addressbook  $TeamName”
     $default_GAL = “Global Adressbook  $TeamName”
$AdressbookPolicy = "Adressbook Policy  $TeamName”


        # GERMAN
        $TeamName = "Mitarbeiter" # 
      
       $intern_AL = "Addressliste (intern) $TeamName"
       $extern_AL = "Addressliste - Kontakte (extern) $TeamName"
       $Groups_AL = "Addressliste Gruppen $TeamName"
     $RoomList_AL = "Raumliste $TeamName"
        $Rooms_AL = "Räume $TeamName"
   $Ressources_AL = "Ausrüstung $TeamName"
     $Offline_GAL = “Offline Addressbuch $TeamName”
     $default_GAL = “Globales Addressbuch $TeamName”
$AdressbookPolicy = "Adressbuchrichtlinie $TeamName”

  # CHECK AT THE below 4 lines and change "visible_for_Team"

# Create Address Lists

*** Change "Manager" at the end of the net 4 lines to the value used above

New-AddressList -Name $intern_AL  -RecipientFilter {(RecipientType -eq 'UserMailbox') -or (RecipientTypeDetails -eq 'SharedMailbox') -or (RecipientType -eq 'Mailuser') -and (CustomAttribute11 -eq "Mitarbeiter")}
New-AddressList -Name $extern_AL  -RecipientFilter {(RecipientType -eq 'MailContact') -and (CustomAttribute11 -eq "Mitarbeiter")}
New-AddressList -Name $Groups_AL -RecipientFilter {(RecipientType -eq 'DynamicDistributionGroup') -or (RecipientType -eq 'MailUniversalDistributionGroup') -or (RecipientType -eq 'MailUniversalSecurityGroup') -and (CustomAttribute11 -eq "Mitarbeiter")}
New-AddressList -Name $RoomList_AL  -RecipientFilter {(RecipientTypeDetails -eq 'RoomList') -and (CustomAttribute11 -eq "Mitarbeiter")}

# Create Offline Address Book
New-OfflineAddressBook -Name $Offline_GAL -AddressLists $intern_AL,$extern_AL,$Groups_AL,$RoomList_AL,$Rooms_AL,$Ressources_AL

# Create Global Address Book INTERNAL only
New-GlobalAddressList  -Name $default_GAL -RecipientFilter "((RecipientType -eq 'UserMailbox') -or (RecipientType -eq 'Mailuser') -or (RecipientTypeDetails -eq 'SharedMailbox')) -and (CustomAttribute11 -eq "Mitarbeiter")"

# Create Address Book Policy
New-AddressBookPolicy -Name $AdressbookPolicy -AddressLists $intern_AL,$extern_AL,$Groups_AL,$RoomList_AL -RoomList "\$RoomList_AL" -OfflineAddressBook “\$Offline_GAL” -GlobalAddressList “\$default_GAL”


 **** How to set custom attributes

# USERS who have different GAL

set-mailbox kasim -CustomAttribute15 ""

***********************************
# objects that are tagged to be exceptionally visible for above

---------------------------------------

  $Manager = "Manager" #

---------------------------------------

set-mailbox USERNAME -CustomAttribute15 $Manager

Set-DistributionGroup "GROUP NAME" -CustomAttribute15 $Manager

Set-UnifiedGroup "GROUP NAME" -CustomAttribute15 $Manager

Set-MailUser USERNAME -CustomAttribute15 $Manager

Set-MailContact USERNAME -CustomAttribute15 $Manager

---------------------------------------

#check wih test user first

Get-Mailbox TESTUSER | Set-Mailbox -AddressBookPolicy $AdressbookPolicy

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