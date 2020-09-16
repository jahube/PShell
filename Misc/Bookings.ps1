Start-transcript
 
$MBX = get-recipient -Resultsize Unlimited | where {$_.RecipientTypeDetails -match "SchedulingMailbox"}

foreach ($M in $MBX) {

Write-Host -ForegroundColor green "collecting permissions for $($user.alias)..."

$stats = Get-MailboxFolderStatistics $MBX.distinguishedname
$stats |  fl identity
$stats |  ? { $_.identity -match 'BookingStaff'} | fl identity
$stats |  ? { $_.identity -match 'calendar'} | fl identity


$stats | ? { $_.containerclass -eq 'IPF.Appointment'}

$stats |  ? { $_.identity -match 'contacts'} | fl identity

Get-MailboxCalendarFolder "$($user.alias):\calendar" |fl

$types = "Contacts","Calendar","Notes","BookingStaff"
$D = $M.distinguishedname
$U = $M.PrimarySmtpAddress.ToString()
foreach($F in (Get-MailboxFolderStatistics $D | ? {$_.foldertype.tostring() -in ($types)})){ $FN = $U + ':' + $F.FolderPath.Replace('/','\');
Try { Get-MailboxFolderPermission $FN -EA stop | fl } catch { write-host $Error[0].Exception.message -F yellow }}

 }

stop-transcript
