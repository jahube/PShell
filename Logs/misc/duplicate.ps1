
#basic
$mail = "alias@domain.com"

get-user $mail | fl
get-recipient -ResultSize unlimited | ? {$_.emailaddresses -match $mail } | fl Name, RecipientType, EmailAddresses, Alias
get-recipient -ResultSize unlimited | where {$_.EmailAddresses -match $mail } | fl Name, RecipientType, EmailAddresses, Alias
get-recipient -ResultSize unlimited | where {$_.alias -match $mail } | fl Name, RecipientType, EmailAddresses, Alias

# mail contacts
get-mailcontact -ResultSize unlimited | ? {$_.emailaddresses -match $mail } | fl Name, RecipientType, EmailAddresses, Alias

# mail box SOFTDELETED
Get-Mailbox -SoftDeletedMailbox | Where {$_.EmailAddresses -match $mail } | select userprincipalname, EmailAddresses, whensoftdeleted  | fl

# mail box PF
Get-Mailbox -PublicFolder | Where {$_.EmailAddresses -match $mail } | select userprincipalname, EmailAddresses, whensoftdeleted  | fl

# mail user
Get-Mailuser -ResultSize unlimited | Where {($_.EmailAddresses -match $mail ) -or ($_.ExternalEmailAddress -match $mail ) -or ($_.ExternalEmailAddress -match $mail ) } |fl Displayname, PrimarySmtpAddress, RecipientType, EmailAddresses, WindowsEmailAddress

# mail user SOFTDELETED
Get-Mailuser -SoftDeleted | Where {($_.PrimarySmtpAddress -match $mail ) -or ($_.ExternalEmailAddress -match $mail) -or ($_.EmailAddresses -match $mail) -or ($_.userprincipalname -match $mail) -or ($_.alias -match $mail)} | select userprincipalname, EmailAddresses,whensoftdeleted | fl

# (mail enabled) public folder aliases
Get-Mailpublicfolder | ? {$_.emailaddresses -match $mail } | fl Displayname, PrimarySmtpAddress, RecipientType, EmailAddresses, WindowsEmailAddress

# Distribution list
Get-DistributionGroup | ? {$_.emailaddresses -match $mail } | fl Name, WindowsEmailAddress, RecipientType, EmailAddresses, Alias, HiddenFromAddressListsEnabled

# Office 365 Group  / mail enabled security group
Get-UnifiedGroup | ? {$_.emailaddresses -match $mail } | fl Name, RecipientType, EmailAddresses, Alias, HiddenFromAddressListsEnabled

# O365 Group SOFTDELETED
Get-AzureADMSDeletedGroup -All:$true | Where {($_.Mail -match $mail ) -or ($_.ProxyAddresses -match $mail)} | fl DisplayName, Mail, ProxyAddresses, SecurityEnabled, GroupTypes




# Onprem .... to be continued

Get-MailboxStatistics | where {($_.DisconnectReason -ne $null) -or ($_.DisconnectDate -ne $null) } | Format-Table DisplayName,Database,DisconnectDate,DisconnectReason

get-ADuser -identity $user | fl

get-remotemailbox
$dbs = Get-MailboxDatabase
$dbs | foreach {Get-MailboxStatistics -Database $_.DistinguishedName} | where {($_.DisconnectReason -ne $null) -or ($_.DisconnectDate -ne $null) } | Format-Table DisplayName,Database,DisconnectDate,DisconnectReason'n
