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

          $Suffix = "Team" 
      
       $intern_AL = "Addresslist (internal) $Suffix"
       $extern_AL = "Addresslist Contacts (external) $Suffix"
       $Groups_AL = "Addresslist Groups $Suffix"
     $RoomList_AL = "Roomlists $Suffix"
        $Rooms_AL = "Rooms $Suffix"
   $Ressources_AL = "Ressources $Suffix"
     $Offline_GAL = “Offline Addressbook $Suffix”
     $default_GAL = “Global Adressbook $Suffix”
$AdressbookPolicy = "Adressbook Policy $Suffix”

  # CHECK AT THE below 4 lines and change "visible_for_Team"

# Create Address Lists
New-AddressList -Name $intern_AL  -RecipientFilter {(RecipientType -eq 'UserMailbox') -or (RecipientTypeDetails -eq 'SharedMailbox') -or (RecipientType -eq 'Mailuser') -and (CustomAttribute11 -eq "visible_for_Team")}
New-AddressList -Name $extern_AL  -RecipientFilter {(RecipientType -eq 'MailContact') -and (CustomAttribute11 -eq "visible_for_Team")}
New-AddressList -Name $Groups_AL -RecipientFilter {(RecipientType -eq 'DynamicDistributionGroup') -or (RecipientType -eq 'MailUniversalDistributionGroup') -or (RecipientType -eq 'MailUniversalSecurityGroup') -and (CustomAttribute11 -eq "visible_for_Team")}
New-AddressList -Name $RoomList_AL  -RecipientFilter {(RecipientTypeDetails -eq 'RoomList') -and (CustomAttribute11 -eq "visible_for_Team")}

# Create Offline Address Book
New-OfflineAddressBook -Name $Offline_GAL -AddressLists $intern_AL,$extern_AL,$Groups_AL,$RoomList_AL,$Rooms_AL,$Ressources_AL

# Create Global Address Book INTERNAL only
New-GlobalAddressList  -Name $default_GAL -RecipientFilter "((RecipientType -eq 'UserMailbox') -or (RecipientType -eq 'Mailuser') -or (RecipientTypeDetails -eq 'SharedMailbox')) -and (CustomAttribute11 -eq "visible_for_Team")"

# Create Address Book Policy
New-AddressBookPolicy -Name $AdressbookPolicy -AddressLists $intern_AL,$extern_AL,$Groups_AL,$RoomList_AL -RoomList "\$RoomList_AL" -OfflineAddressBook “\$Offline_GAL” -GlobalAddressList “\$default_GAL”


 **** How to set custom attributes

# USERS who have different GAL

set-mailbox kasim -CustomAttribute15 "Special_GAL"

***********************************
# objects that are tagged to be exceptionally visible for above

set-mailbox kasim -CustomAttribute15 "visible_for_Team"

Set-DistributionGroup abc -CustomAttribute15 "visible_for_Team"

Set-UnifiedGroup test2 -CustomAttribute15 "visible_for_Team"

#check wih test user first
Get-Mailbox TESTUSER |  Where { $_.CustomAttribute15 -eq "Special_GAL" } | Set-Mailbox -AddressBookPolicy $AdressbookPolicy

# later assign to all users if it is confirmed to be running
Get-Mailbox -Filter {(RecipientType -eq 'UserMailbox')} -resultsize unlimited |  Where { $_.CustomAttribute15 -eq "Custom_EXCLUDE_Value" } | Set-Mailbox -AddressBookPolicy $AdressbookPolicy

# update Addresslists
get-AddressList | % { Set-AddressList -Identity $_.identity }