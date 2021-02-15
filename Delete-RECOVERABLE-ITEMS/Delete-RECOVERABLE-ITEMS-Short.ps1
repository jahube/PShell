Set-ExecutionPolicy RemoteSigned

# install
Install-Module -Name ExchangeOnlineManagement

$user = "email@affected-user.com"

$admin = "admin@domain.com"

# connect
Connect-ExchangeOnline -UserPrincipalName $admin -ShowProgress $true

# assign permissions
New-ManagementRoleAssignment -Role "Mailbox Import Export" -User $ADMIN
New-ManagementRoleAssignment -Role "Mailbox Search" -User $ADMIN
Add-RoleGroupMember "Compliance Management" -Member $ADMIN

# IMPORTANT - connect AGAIN to update permission - IMPORTANT <<<
Connect-ExchangeOnline -UserPrincipalName $admin -ShowProgress $true

# PERMISSIONS
# Enable-OrganizationCustomization -confirm:$false # remove first "#" if you get the message that it is not enabled

# IMPORTANT - below has ~ 2h replication time - IMPORTANT <<<
Set-Mailbox $user -SingleItemRecoveryEnabled $false
Set-Mailbox $user -ElcProcessingDisabled $true

# delete items bigger than 8 MB *fast 1-10 minutes 
Search-Mailbox $user -SearchQuery size>8200000 -SearchDumpsterOnly –DeleteContent

# delete all dumpster items * slow 30 Minutes <-> 6h
Search-Mailbox $user -SearchDumpsterOnly -DeleteContent

# get RESULT
Get-MailboxFolderStatistics $user -FolderScope RecoverableItems | FL Name,FolderAndSubfolderSize,ItemsInFolderAndSubfolders

