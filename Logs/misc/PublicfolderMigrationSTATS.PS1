#EXO PS:
# install-module exchangeonlinemanagement
# connect-exchangeonline -userprincipalname "ADMIN@DOMAIN.com"

get-mailbox -publicfolder | FT Displayname,userprincipalname,primarySMTPaddress
 
$path = "C:\temp"
$PFMBX = "<address of cloud public folder mailbox>"
 
Get-MigrationUserStatistics $PFMBX -DiagnosticInfo Verbose -IncludeReport | Export-CliXML $path\EXO_PFmbxmigUserStats.xml

Get-PublicFolderMigrationRequest | Get-PublicFolderMigrationRequestStatistics -IncludeReport -DiagnosticInfo Verbose | Export-CliXML $path\EXO_PFMigReq.xml

Get-MigrationBatch -DiagnosticInfo Verbose -IncludeReport | ?{$_.MigrationType.ToString() -eq "PublicFolder"} | export-clixml $path\EXO_PFMigbatch.xml