
         #  MODIFY below  

$ADMIN = "admin@domain.com"

$USER = "user@your-domain.com"

#  <<< ====  RUN BELOW + (1) , (2) or (3) =======>>>

Set-ExecutionPolicy RemoteSigned
Install-Module -Name ExchangeOnlineManagement
Connect-ExchangeOnline -UserPrincipalName $admin -ShowProgress $true
New-ManagementRoleAssignment -Role "Mailbox Import Export" -User $ADMIN
# Enable-OrganizationCustomization -confirm:$false

# IMPORTANT - connect AGAIN to update permission - IMPORTANT <<<
Connect-ExchangeOnline -UserPrincipalName $admin -ShowProgress $true

#  <<< ========      (1) ALL         ============>>>

get-recoverableitems -Identity $user -ResultSize unlimited | restore-recoverableitems -NoOutput

#  <<< ========      (2) Item Type   ============>>>

         # MODIFY #

$Items = "IPM.Note"          # Examples  -->   "IPM.Note"  "IPM.Appointment"   "IPM.Contact"

$search = get-recoverableitems -Identity $user -FilterItemType $Items -ResultSize unlimited
$search | ft subject,SourceFolder,ItemClass,LastParentPath,LastModifiedTime    #   <-- preview  
$search | restore-recoverableitems                                             #   <-- restore 

#  <<< =========      (3) Folder Type     ========>>>

              #  MODIFY #

$foldertype = "sentitems"    # Examples  -->   "inbox"  "calendar" "sentitems"

$Stats = (Get-MailboxFolderStatistics $user).where( {$_.foldertype.tostring() -eq $foldertype })
$search = (get-recoverableitems $user).where({$_.LastParentPath -eq $Stats[0].name })
$search | fl subject,SourceFolder,ItemClass,LastParentPath                     #   <-- preview  
$search | restore-recoverableitems                                             #   <-- restore