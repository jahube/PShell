
$NewRListName = 'RoomList'

$ts = Get-Date -Format yyyyMMdd_hhmmss
$FormatEnumerationLimit = -1

$DesktopPath = ([Environment]::GetFolderPath('Desktop'))
$logsPATH =mkdir "$DesktopPath\MS-Logs\$ts" # creates MS-Logs on desktop + Timestamp
Start-Transcript "$logsPATH\OnPremises$ts.txt"

$RoomMailboxes = 
$RoomMailboxes | ft name,mailNickname,mail,targetAddress # Preview

$RoomLISTs = Get-DistributionGroup -Filter * -ResultSize Unlimited | Where {$_.RecipientTypeDetails -eq "RoomList"}
if(!($RoomLISTs)) {
$list = New-DistributionGroup -Name $NewRListName -RoomList
$RoomMailboxes | % { Add-DistributionGroupMember -Identity $list.PrimarySmtpAddress -Member $_.Distinguishedname }
$RoomLISTs = Get-DistributionGroup -Filter * -ResultSize Unlimited | Where {$_.RecipientTypeDetails -eq "RoomList"}
}

$RoomLISTs | FT SamAccountName,Displayname,Identity,PrimarySMTPaddress -Autosize

$RoomLISTs | Export-Csv -NoTypeInformation "$logsPATH\roomLISTs.csv"

$LISTmembers = Get-DistributionGroupMember $list.PrimarySmtpAddress 

if(!($LISTmembers)) -eq $false) {$LISTmembers | Export-Csv -NoTypeInformation "$logsPATH\LISTmembers.csv"}

if(!($RoomMailboxes)) {
foreach ($Room in $RoomMailboxes) { 
$roommail = $Room.userprincipalname

ROOMUSER CLOUD 

Get-Mailbox -Identity $roommail | Get-MailboxPermission | `
where {$_.user.tostring() -ne "NT AUTHORITY\SELF" -and $_.IsInherited -eq $false} | `
Select Identity,User,@{Name='Access Rights';Expression={[string]::join(', ', $_.AccessRights)}} | `
Export-Csv -NoTypeInformation "$logsPATH\$roommail.MBXpermissions.csv"
 
Get-MailboxFolderPermission -Identity "$($roommail):\Calendar" | `
Out-File -FilePath "$logsPATH\$roommail.folderpermission.txt"
 
Get-Mailbox -Identity $roommail | `
Out-File -FilePath "$logsPATH\$roommail.mailbox.txt"

get-recipient -Identity $roommail| `
Out-File -FilePath "$logsPATH\$roommail.recipient.txt"

Get-CASMailbox -Identity $roommail| `
Out-File -FilePath "$logsPATH\$roommail.Casmailbox.txt"

Get-Mailbox $roommail | Get-CalendarProcessing | Out-File -FilePath "$logsPATH\$roommail.RoomCalendarProcessing.txt"
}
}

######END SCRIPT ##########################
Stop-Transcript

$destination = "$DesktopPath\MS-Logs\Logs_$ts.zip"
Add-Type -assembly “system.io.compression.filesystem”
[io.compression.zipfile]::CreateFromDirectory($logsPATH, $destination) # ZIP
Invoke-Item $DesktopPath\MS-Logs # open file manager