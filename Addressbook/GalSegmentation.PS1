
# source https://gallery.technet.microsoft.com/GAL-Segmentation-or-GAL-245d9440

Example filter
get-recipient -ResultSize unlimited -RecipientPreviewFilter {((RecipientType -eq 'UserMailbox' -or RecipientTypeDetails -eq 'SharedMailbox' -or RecipientType -eq 'Mailuser') -and ( UserPrincipalName -like '*DOMAIN.com' ))}

How to set custom attributes

set-mailbox kasim -CustomAttribute1 ABC

Set-DistributionGroup abc -CustomAttribute1 ABC

Set-UnifiedGroup test2 -CustomAttribute1 ABC