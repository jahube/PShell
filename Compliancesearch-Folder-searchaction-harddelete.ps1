$USER = "affecteduser@DOMAIN.com"

$searchname = "NEW SEARCH NAME"

$USER = "ADMIN@DOMAINcom"
 
$foldername = "inbox"

Connect-ExchangeOnline -userprincipalname $admin

$ID= (get-mailboxfolderstatistics -identity $USER -folderscope $foldername).folderid

get-mailboxfolderstatistics -identity $USER -folderscope $foldername | fl *Items*,*Size*

Connect-IPPSSession -userprincipalname $admin

New-ComplianceSearch -Name $searchname -ExchangeLocation $USER -ContentMatchQuery "FolderID:$ID"

Start-ComplianceSearch -Identity $searchname

get-ComplianceSearch -Identity $searchname

New-ComplianceSearchAction -SearchName $searchname -Purge -PurgeType HardDelete