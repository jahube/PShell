
# source https://gallery.technet.microsoft.com/GAL-Segmentation-or-GAL-245d9440

Example filter

get-recipient -ResultSize unlimited -RecipientPreviewFilter {((RecipientType -eq 'UserMailbox' -or RecipientTypeDetails -eq 'SharedMailbox' -or RecipientType -eq 'Mailuser') -and ( UserPrincipalName -like '*DOMAIN.com' ))}

############ Tag O365 Group ######################################################################################################

# Select O365 Group
$O365Group = Get-UnifiedGroup -resultsize unlimited

$selected = $O365Group | Out-Gridview -T "Select O365-Group to filter" -OutputMode single

###################################################################################################################################
# check Filter
get-recipient -ResultSize unlimited -RecipientPreviewFilter -RecipientFilter {(MemberOfGroup -eq "$($selected.DistinguishedName)")

get-recipient -ResultSize unlimited -RecipientPreviewFilter -RecipientFilter {(MemberOfGroup -eq "$($selected.Name)")

###################################################################################################################################
# select Tag for latr use in Addressbook Policies etc
$CustomAttribute = "GroupTAG"
# OR
$CustomAttribute = $selected.Name
$CustomAttribute
###################################################################################################################################
# Tag Group Membership on Mailboxes of the Members

$Members = Get-UnifiedGroupLinks $selected.ExternalDirectoryObjectId -LinkType Members

Foreach ($M in $Members) { set-mailbox $M.DistinguishedName -CustomAttribute11 $CustomAttribute }

########## Tag legacy Distribution List / Security Group  ########################################################################

# Select legacy Distribution List / Security Group

$DLs = Get-get-distributiongroup -resultsize unlimited

$selected = $DLs | Out-Gridview -T "Select O365-Group to filter" -OutputMode single

###################################################################################################################################
# check Filter
get-recipient -ResultSize unlimited -RecipientPreviewFilter -RecipientFilter {(MemberOfGroup -eq "$($selected.DistinguishedName)")

get-recipient -ResultSize unlimited -RecipientPreviewFilter -RecipientFilter {(MemberOfGroup -eq "$($selected.Name)")

###################################################################################################################################
# select Tag for latr use in Addressbook Policies etc
$CustomAttribute = "GroupTAG"
# OR
$CustomAttribute = $selected.Name
$CustomAttribute
###################################################################################################################################
# Tag Group Membership on Mailboxes of the Members

$Members = Get-DistributionGroupMember $selected.ExternalDirectoryObjectId

Foreach ($M in $Members) { set-mailbox $M.DistinguishedName -CustomAttribute11 $CustomAttribute }

###################################################################################################################################

Get-UnifiedGroupLinks GROUP_NAME -LinkType Members

Get-DistributionGroupMember GROUP_NAME

set-mailbox MAILBOX_NAME -CustomAttribute11 ABC

Set-DistributionGroup MAILBOX_NAME -CustomAttribute11 ABC

Set-UnifiedGroup MAILBOX_NAME -CustomAttribute11 ABC