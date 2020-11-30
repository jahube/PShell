FULL ACCESS

• full access (MailboxPermission)

Add-MailboxPermission -Identity "Terry Adams" -User "Kevin Kelly" -AccessRights FullAccess -InheritanceType All

• Automapping (msExchDelegateListLink)

$A = Get-ADUser a3
$b = Get-ADUser TEST
$dn = $b.DistinguishedName
Set-ADUser -Identity $A.DistinguishedName -Add @{msExchDelegateListLink=$dn}
get-ADUser -Identity $A.DistinguishedName -Properties msExchDelegateListLink | select -ExpandProperty msExchDelegateListLink


ACLABLE 

Set-OrganizationConfig -ACLableSyncedObjectEnabled $True

•	update mailboxes (ACLable user MBX onprem)

$mbxs = get-mailbox -ResultSize unlimited | ? { $_.recipienttypedetails -eq "UserMailbox" }
Foreach ($M in $mbxs) { Set-ADUser $M.distinguishedname -Replace @{msExchRecipientDisplayType=-1073741818} }

•	update remotemailboxes (ACLable remote MBX cloud)

$RmtMbx = get-remotemailbox -ResultSize unlimited | ? { $_.recipienttypedetails -eq 'RemoteUserMailbox' } 
Foreach ($R in $RmtMbx) { Set-ADUser $R.distinguishedname -Replace @{msExchRecipientDisplayType=-1073740282} }


# SENDAS ACCESS

## pending doublecheck to not mix up sendonbehalf + sendas / remotemailbox
# Local --> Cloud has to be set from Onprem
# Cloud --> Local has to be set from Cloud

#onprem "Send As"
$MBX = "accessed@mailbox" $user = "accessing@USER"
$M = get-aduser -filter { userprincipalname -eq $MBX }
$U = get-aduser -filter { userprincipalname -eq $user}
Add-ADPermission -Identity $M.distinguishedname -User $U.distinguishedname -AccessRights ExtendedRight -ExtendedRights "Send As"

#cloud SendAs
$MBX = "accessed@mailbox"
$user = "accessing@USER"

Add-RecipientPermission -Identity $MBX -Trustee $user -AccessRights SendAs -Confirm:$false


# ON BEHALF ACCESS (outlook) 
## pending doublecheck to not mix up sendonbehalf + sendas / remotemailbox

# Local --> Cloud has to be set from Onprem
# Cloud --> Local has to be set from Cloud

cloud > onprem mailuser
set-mailbox MBX-grantonbehalfto USER

onprem remotemailbox > onpem mailbox
set-remotemailbox MBX -grantonbehalfto USER

