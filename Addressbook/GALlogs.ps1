start-transcript -verbose

Write-host "`n`nGet-AddressList" -F yellow
Get-AddressList |FL

Write-host "`n`nGet-GlobalAddressList" -F yellow
Get-GlobalAddressList | FL

Write-host "`n`nGet-OfflineAddressBook" -F yellow
Get-OfflineAddressBook | FL 

Write-host "`n`nGet-AddressBookPolicy" -F yellow
Get-AddressBookPolicy | FL 

Write-host "`n`nGet-mailbox" -F yellow
Get-mailbox “identity of a mailbox that has the problem with Address Lists” | FL
 
Write-host "`n`nGet-AddressList |FL name, recipientfilter" -F yellow
Get-AddressList | FL name, recipientfilter

$ALs = Get-AddressList
Foreach ($AL in $ALs){
 
Write-Host "`n`n $($AL.Name) LdapRecipientFilter `n"
Get-Recipient -RecipientPreviewFilter (Get-AddressList $AL.Name).LdapRecipientFilter | FT -AutoSize
 
Write-Host "`n`n $($AL.Name) RecipientFilter `n"
Get-Recipient -RecipientPreviewFilter (Get-Addresslist $AL.Name).recipientfilter | FT -AutoSize
}
 
stop-transcript


