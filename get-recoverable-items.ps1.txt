Set-ExecutionPolicy RemoteSigned
# connect
$admin = "admin@domain.com"

Install-Module -Name ExchangeOnlineManagement
Connect-ExchangeOnline -UserPrincipalName $admin -ShowProgress $true

#assign permissions
New-ManagementRoleAssignment -Role "Mailbox Import Export" -User $ADMIN
New-ManagementRoleAssignment -Role "Mailbox Search" -User $ADMIN
Add-RoleGroupMember "Organization Management" -Member $ADMIN
Add-RoleGroupMember "Discovery Management" -Member $ADMIN
Add-RoleGroupMember "Compliance Management" -Member $ADMIN

# if customization not enabled yet, run the below first and retry the above (command takes 1-2 minutes)
# Enable-OrganizationCustomization -confirm:$false

# GET-RECOVERABLEITEMS

$user = "affected@user.com"
$start = Get-Date -date $(Get-Date).AddDays(-90)
$end = Get-Date -date $(Get-Date)

$search = get-recoverableitems -Identity $user -FilterStartTime $start -FilterEndTime $end
$search | fl subject,SourceFolder,ItemClass

$search | restore-recoverableitems

-SourceFolder PurgedItems,DeletedItems,RecoverableItems
-FilterItemType

IPM.Appointment (Meetings and appointments)
IPM.Contact
IPM.File
IPM.Note
IPM.Task

-Format (Get-Culture).DateTimeFormat.ShortDatePattern # optional date adjustment parameter


* folder specific

$foldername = "inbox"
$ID= (get-mailboxfolderstatistics -identity $USER -folderscope $foldername).folderid.toString()

$ID = "GUID from Rave folder statistics / folder folderID"

$search = get-recoverableitems -Identity $user -LastParentFolderID $ID
$search | fl subject,SourceFolder,ItemClass

$search | restore-recoverableitems
