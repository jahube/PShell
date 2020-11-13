$NewRListName = 'RoomList'
$ts = Get-Date -Format yyyyMMdd_hhmmss
$FormatEnumerationLimit = -1
$DesktopPath = ([Environment]::GetFolderPath('Desktop'))
$logsPATH =mkdir "$DesktopPath\MS-Logs\$ts" # creates MS-Logs on desktop + Timestamp
Start-Transcript "$logsPATH\OnPremises$ts.txt" -Verbose
$RoomMailboxes = Get-MailBox | Where {$_.ResourceType -eq "Room"}
$RoomMailboxes | ft name,alias,primarysmtpaddress,userprincipalname # Preview
$RoomLISTs = Get-DistributionGroup -Filter * -ResultSize Unlimited | Where {$_.RecipientTypeDetails -eq "RoomList"}
if($RoomLISTs) {foreach ($RL in $RoomLISTs) {
Write-host "`n`n $($RL.DisplayName) `n" -F green
$LISTmembers = Get-DistributionGroupMember $RL.distinguishedname
$LISTmembers | ft name,identity,alias,primarysmtpaddress,RecipientTypeDetails | Out-File -FilePath "$logsPATH\$($RL.DisplayName).Roomlist.txt"
$LISTmembers | ft name,identity,alias,primarysmtpaddress,RecipientTypeDetails | Export-Csv -NoTypeInformation "$logsPATH\$($RL.DisplayName).Roomlist.csv"
$LISTmembers | ft name,identity,alias,primarysmtpaddress,RecipientTypeDetails } }

if(!($RoomLISTs)) {
$list = New-DistributionGroup -Name $NewRListName -RoomList
$RoomMailboxes | % { Add-DistributionGroupMember -Identity $list.distinguishedname -Member $_.Distinguishedname }
$RoomLISTs = Get-DistributionGroup -Filter * -ResultSize Unlimited | Where {$_.RecipientTypeDetails -eq "RoomList"}
$LISTmembers = Get-DistributionGroupMember $list.distinguishedname
$LISTmembers | ft name,alias,primarysmtpaddress,RecipientTypeDetails 
}
$RoomLISTs | FT SamAccountName,Displayname,Identity,PrimarySMTPaddress -Autosize
$RoomLISTs | Export-Csv -NoTypeInformation "$logsPATH\roomLISTs.csv"
if($LISTmembers) {$LISTmembers | Export-Csv -NoTypeInformation "$logsPATH\LISTmembers.csv"}
if($RoomMailboxes) {
foreach ($Room in $RoomMailboxes) { 
$roomDST = $Room.distinguishedname
if ($Room.name -match '@') { $roommail = $Room.name } else { $roommail = $Room.primarysmtpaddress.Replace('?','@') }
Get-MailBox $roommail | Export-Csv -NoTypeInformation "$logsPATH\$roommail.csv"
Get-Mailbox -Identity $roommail | Get-MailboxPermission | `
where {$_.user.tostring() -ne "NT AUTHORITY\SELF" -and $_.IsInherited -eq $false} | `
Select Identity,User,@{Name='Access Rights';Expression={[string]::join(', ', $_.AccessRights)}} | `
Export-Csv -NoTypeInformation "$logsPATH\$roommail.MBXpermissions.csv"
 
foreach($F in (Get-MailboxFolderStatistics $roomDST | ? {$_.foldertype.tostring() -eq "Calendar"})){ $FN = $roommail + ':' + $F.FolderPath.Replace('/','\');
Try { get-MailboxFolderPermission $FN -EA stop | fl | Out-File -FilePath "$logsPATH\$roommail.folderpermission.txt" } catch { write-host $Error[0].Exception.message -F yellow }}
Get-Mailbox -Identity $roomDST | fl | Out-File -FilePath "$logsPATH\$roommail.mailbox.txt"
get-recipient -Identity $roomDST | fl | Out-File -FilePath "$logsPATH\$roommail.recipient.txt"
Get-CASMailbox -Identity $roomDST | fl | Out-File -FilePath "$logsPATH\$roommail.Casmailbox.txt"
Get-Mailbox $roomDST | Get-CalendarProcessing | fl | Out-File -FilePath "$logsPATH\$roommail.RoomCalendarProcessing.txt"
}
}
######END SCRIPT ##########################
Stop-Transcript
$destination = "$DesktopPath\MS-Logs\Logs_$ts.zip"
Add-Type -assembly “system.io.compression.filesystem”
[io.compression.zipfile]::CreateFromDirectory($logsPATH, $destination) # ZIP
Invoke-Item $DesktopPath\MS-Logs # open file manager