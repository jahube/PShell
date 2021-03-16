# MailBox Audit Logs
# $OfflineMode = $false # collect + parse logs
# $OfflineMode = $true # parse logs Offline

$OfflineMode=$true

$start = "-90" # last -x days

#desktop/MS-Logs+Timestamp
$ts=Get-Date-FormatyyyyMMdd_hhmmss
$DesktopPath=([Environment]::GetFolderPath('Desktop'))
$logsPATH=mkdir"$DesktopPath\MS-Logs\Mailbox-Audit-Logs_$ts"

Start-Transcript"$logsPATH\Transcript_$ts.txt"
$FormatEnumerationLimit=-1

IF($OfflineMode-eq$false){
IF(!@(Get-PSSession|where{$_.State-ne"broken"})){
IF(!@(Get-InstalledModuleExchangeOnlineManagement-ErrorActionSilentlyContinue)){install-moduleexchangeonlinemanagement-ScopeCurrentUser}
IF(!@($Credentials)){$Credentials=Get-credential};IF(!@($ADMIN)){$ADMIN=$Credentials.UserName}
Try{Connect-ExchangeOnline-Credential$Credentials}catch{Connect-ExchangeOnline-UserPrincipalName$ADMIN}}
IF(!($Credentials.UserName-in(get-RoleGroupMember"OrganizationManagement").primarySMTPaddress)){Add-RoleGroupMember"OrganizationManagement"-Member$ADMIN
Try{Connect-ExchangeOnline-Credential$Credentials}catch{Connect-ExchangeOnline-UserPrincipalName$ADMIN}}

IF(!($USER)){$MBXs=get-mailbox-ResultSizeunlimited;
IF($MBXs.Count-gt"400"){$USER=Read-Host-Prompt"AffectedUser[Userprincipalname]"}
ELSE{$USER=@($MBXs|selectPr*ess,Dis*me,Use*me|OGV-P-T"SelectUser").userprincipalname}}
IF(!($start)){[int]$start="-90"}
IF(!($data)){$data=Search-MailboxAuditLog-Identity$user-ShowDetails-StartDate(get-date).AddDays($start)-EndDate(get-date)}

$data|Export-Clixml"$logsPATH\mailboxlogs.xml"

get-mailbox$user|selectAuditEnabled
get-mailbox$user|select-expandpropertyauditadmin
get-mailbox$user|select-expandpropertyauditdelegate
get-mailbox$user|select-expandpropertyauditowner}

Else{$FileBrowser=New-ObjectSystem.Windows.Forms.OpenFileDialog-Property@{
InitialDirectory=[Environment]::GetFolderPath('Desktop')
Filter='XMLFiles(*.xml)|*.xml'}
$null=$FileBrowser.ShowDialog()
$Data=Import-Clixml$FileBrowser.FileName}

$data|select-objectoperation,clientprocessname,clientinfostring,ClientVersion,clientip-Unique|ft>"$logsPATH\Types-Unique.txt"
$softdelete=$data|where{$_.operation-eq"softdelete"}|selectoperation,clientprocessname,clientinfostring,lastaccessed,clientip,ClientVersion,FolderPathName,SourceItemFolderPathNamesList,SourceItemSubjectsList
$harddelete=$data|where{$_.operation-eq"harddelete"}|selectoperation,clientprocessname,clientinfostring,lastaccessed,clientip,ClientVersion,FolderPathName,SourceItemFolderPathNamesList,SourceItemSubjectsList
$MoveToDltd=$data|where{$_.operation-eq"MoveToDeletedItems"}|selectoperation,clientprocessname,clientinfostring,lastaccessed,clientip,ClientVersion,FolderPathName,SourceItemFolderPathNamesList,SourceItemSubjectsList

$data|groupoperation,clientprocessname,clientinfostring,ClientVersion,LogonType,clientip|selectcount,Name|Sortcount-Descending|ft>"$logsPATH\Types-Summary.txt"
$harddelete|FT>"$logsPATH\harddelete-Details.txt"
$harddelete|Export-CSV"$logsPATH\harddelete-Details.csv"-NoTypeInformation
$harddelete|groupoperation,clientprocessname,clientinfostring,ClientVersion,clientip,LogonType,CrossMailboxOperation,DestMailboxOwnerUPN,ExternalAccess|selectcount,Name>"$logsPATH\harddelete.txt"
$harddelete|groupoperation,clientprocessname,clientinfostring,LogonType,ClientVersion|selectcount,Name>"$logsPATH\harddelete-Summary.txt"

$softdelete|FT>"$logsPATH\softdelete-Details.txt"
$softdelete|groupoperation,clientprocessname,clientinfostring,ClientVersion,clientip,LogonType,CrossMailboxOperation,DestMailboxOwnerUPN,ExternalAccess|selectcount,Name>"$logsPATH\softdelete.txt"
$softdelete|groupoperation,clientprocessname,clientinfostring,LogonType,ClientVersion|selectcount,Name>"$logsPATH\softdelete-Summary.txt"
$softdelete|Export-CSV"$logsPATH\softdelete-Details.csv"-NoTypeInformation

$MoveToDltd|FT>"$logsPATH\MoveToDltd-Details.txt"
$MoveToDltd|groupoperation,clientprocessname,clientinfostring,ClientVersion,clientip,LogonType,CrossMailboxOperation,DestMailboxOwnerUPN,ExternalAccess|selectcount,Name>"$logsPATH\MoveToDltd.txt"
$MoveToDltd|groupoperation,clientprocessname,clientinfostring,LogonType,ClientVersion|selectcount,Name>"$logsPATH\MoveToDltd-Summary.txt"
$MoveToDltd|Export-CSV"$logsPATH\MoveToDltd-Details.csv"-NoTypeInformation

$data|FT>"$logsPATH\ALL-Details.txt"
$data|groupoperation,clientprocessname,clientinfostring,ClientVersion,LogonType,clientip,CrossMailboxOperation,DestMailboxOwnerUPN,ExternalAccess|selectcount,Name>"$logsPATH\ALL.txt"
$data|groupoperation,clientprocessname,clientinfostring,LogonType,ClientVersion,clientip|selectcount,Name>"$logsPATH\ALL-Summary.txt"
$data|Export-CSV"$logsPATH\ALL-Details.csv"-NoTypeInformation

Stop-Transcript

Compress-Archive-Path$logsPATH-DestinationPath"$DesktopPath\MS-Logs\Mailbox-Audit-Logs_$($USER.replace('@',"-"))_$ts.Zip"-Force#ZipLogs
Invoke-Item$DesktopPath\MS-Logs#openfilemanager
$title="MailboxAuditLogOverviewfor[$user]from$((get-date).AddDays($start))"
$data|groupoperation,clientprocessname,clientinfostring,ClientVersion,LogonType,clientip|selectcount,Name|Sortcount,Operation-Descending|Out-GridView-T$title
#end