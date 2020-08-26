
$NewRListName = 'RoomList'

$ts = Get-Date -Format yyyyMMdd_hhmmss
$FormatEnumerationLimit = -1

$DesktopPath = ([Environment]::GetFolderPath('Desktop'))
$logsPATH =mkdir "$DesktopPath\MS-Logs\$ts" # creates MS-Logs on desktop + Timestamp
Start-Transcript "$logsPATH\OnPremises$ts.txt"

Set-ADServerSettings -ViewEntireForest $true

$RoomMailboxes = Get-ADUser -Filter * -Properties * | `
where {($_.msExchRecipientTypeDetails -eq '16') -or ($_.msExchRecipientDisplayType -eq '7')}
$RemoteRooms = Get-ADUser -Filter * -Properties * | `
where {($_.msExchRecipientTypeDetails -eq '8589934592') -or ($_.msExchRecipientDisplayType -eq '-2147481850')}
$RoomMailboxes | ft name,mailNickname,mail,targetAddress # Preview
$RemoteRooms | ft name,mailNickname,mail,targetAddress # Preview

$RoomLISTs = Get-DistributionGroup -Filter * -ResultSize Unlimited | Where {$_.RecipientTypeDetails -eq "RoomList"}
if([string]::IsNullOrEmpty($RoomLISTs) -eq $true) {
$list = New-DistributionGroup -Name $NewRListName -RoomList
$RoomMailboxes | % { Add-DistributionGroupMember -Identity $list.PrimarySmtpAddress -Member $_.Distinguishedname }
$RoomLISTs = Get-DistributionGroup -Filter * -ResultSize Unlimited | Where {$_.RecipientTypeDetails -eq "RoomList"}
}
$RemoteRooms | % { Add-DistributionGroupMember -Identity $list.PrimarySmtpAddress -Member $_.Distinguishedname }
$RoomLISTs | FT SamAccountName,Displayname,Identity,PrimarySMTPaddress -Autosize
$RoomLISTs | Export-Csv -NoTypeInformation "$logsPATH\roomLISTs.csv"
$LISTmembers = Get-DistributionGroupMember $list.PrimarySmtpAddress 
if([string]::IsNullOrEmpty($LISTmembers) -eq $false) {$LISTmembers | Export-Csv -NoTypeInformation "$logsPATH\LISTmembers.csv"}

if([string]::IsNullOrEmpty($RoomMailboxes) -eq $false) {
foreach ($Room in $RoomMailboxes) { 
$roommail =$Room.userprincipalname

ldifde -f "$logsPATH\$roommail.LFIDE.txt"-r "(UserPrincipalName=$roommail)"

Get-ADUser -SearchBase $Room.DistinguishedName -Filter * -Properties * | `
Out-File -FilePath "$logsPATH\$roommail.AD.txt"

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

### remote-mailboxes ##

if([string]::IsNullOrEmpty($RemoteRooms) -eq $false) {
foreach ($RemoteRoom in $RemoteRooms) {  
$roommail = $RemoteRoom.userprincipalname

ldifde -f "$logsPATH\$roommail.LFIDE.RR.txt"-r "(UserPrincipalName=$roommail)"

Get-ADUser -SearchBase $RemoteRoom.DistinguishedName -Filter * -Properties * | `
Out-File -FilePath "$logsPATH\$roommail.AD.RR.txt"

Get-RemoteMailbox -Identity $roommail | select Name,@{n="Rights";e={(Get-MailboxPermission $_.Identity).accessrights}} | `
Export-Csv -NoTypeInformation "$logsPATH\$roommail.MBXpermissions.RR.1.csv"

Get-RemoteMailbox -Identity $roommail | `
Out-File -FilePath "$logsPATH\$roommail.mailbox.RR.txt"

get-recipient -Identity $roommail| `
Out-File -FilePath "$logsPATH\$roommail.recipient.RR.txt"

   }
}
######END SCRIPT ##########################
Stop-Transcript

$destination = "$DesktopPath\MS-Logs\Logs_$ts.zip"
Add-Type -assembly “system.io.compression.filesystem”
[io.compression.zipfile]::CreateFromDirectory($logsPATH, $destination) # ZIP
Invoke-Item $DesktopPath\MS-Logs # open file manager