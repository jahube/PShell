Set-ExecutionPolicy RemoteSigned

# install
Install-Module -Name ExchangeOnlineManagement

# connect
$admin = "admin@domain.com"
Connect-ExchangeOnline -UserPrincipalName $admin -ShowProgress $true

# assign permissions
New-ManagementRoleAssignment -Role "Mailbox Import Export" -User $ADMIN
# Enable-OrganizationCustomization -confirm:$false

# IMPORTANT - connect AGAIN to update permission - IMPORTANT <<<
Connect-ExchangeOnline -UserPrincipalName $admin -ShowProgress $true

# GET-RECOVERABLEITEMS
$user = "affected@user.com"

#all in one
get-recoverableitems -Identity $user -ResultSize unlimited | restore-recoverableitems -NoOutput

# check + restore changed/deleted last 14 days

$search = get-recoverableitems -Identity $user -ResultSize unlimited
$search = $search | where { $_.LastModifiedTime -gt (Get-Date).AddDays(-14) }
$search | ft subject,SourceFolder,ItemClass
$search | restore-recoverableitems


# check + restore + by original item date
$user = "affected@user.com"
$start = Get-Date -date $(Get-Date).AddDays(-90)
$end = Get-Date -date $(Get-Date)
$search = get-recoverableitems -Identity $user -FilterStartTime (Get-Date).AddDays(-90) -FilterEndTime (Get-Date)
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

$user="affected@user.com"
$folder = 'sent items'
$search = (get-recoverableitems $user).where({$_.LastParentPath -match $folder -or $_.LastParentPath -eq $folder})
$search | fl subject,SourceFolder,ItemClass,LastParentPath
$search | restore-recoverableitems

* folder TYPE

$user="affected@user.com"
$foldertype = "sentitems"
$Stats = (Get-MailboxFolderStatistics $user).where( {$_.foldertype.tostring() -eq $foldertype })
$search = (get-recoverableitems $user).where({$_.LastParentPath -eq $Stats[0].name })
$search | fl subject,SourceFolder,ItemClass,LastParentPath
$search | restore-recoverableitems