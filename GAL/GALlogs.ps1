$VerbosePreference = 'Continue'
$FormatEnumerationLimit=-1

start-transcript -verbose
 
Get-AddressList |FL

Get-GlobalAddressList |FL

Get-OfflineAddressBook | FL 

Get-AddressBookPolicy | FL 

Get-mailbox “identity of a mailbox that has the problem with the AL” | FL 
Get-AddressList |FL name, recipientfilter

$ALs = Get-AddressList
Foreach ($AL in $ALs){
 
Write-Host "$($AL.Name) LdapRecipientFilter"; Write-Host "`n"
Get-Recipient -RecipientPreviewFilter (Get-AddressList $AL.Name).LdapRecipientFilter
 
Write-Host "`n"; Write-Host "$($AL.Name) RecipientFilter"; Write-Host "`n"
Get-Recipient -RecipientPreviewFilter (Get-Addresslist $AL.Name).recipientfilter
}
 
stop-transcript


