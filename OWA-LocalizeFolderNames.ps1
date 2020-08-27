
# OWA-LocalizeFolderNames

##################################
# for all mailboxes progress bar #
##################################

$param = @{
  Identity = $MBX[$M] 
  Language = "DE-DE"
TimeFormat = "HH:mm"
DateFormat = "dd.MM.yyyy"
  TimeZone = "W. Europe Standard Time"
LocalizeDefaultFolderName = $true
   Confirm = $false }

$mbxs = get-mailbox -ResultSize unlimited; $count= $MBXs.count
[System.Collections.ArrayList]$MBX = $mbxs.userprincipalname
for ($M = 0; $M -lt $MBX.count; $M++) { $S =" [MBX] ($($M+1)/$count)  [Time]"
$A = "Changing Folder languange [$($param.Language)]  [Mailbox Count] ($($M+1)/$count) [Mailbox] $($MBX[$M])"
Write-Progress -Activity $A -Status $S -PercentComplete (($M/$count)*100) -SecondsRemaining ($count-$M) ;
Try { Set-MailboxRegionalConfiguration @param } catch { Write-Host $Error[0].Exception.Message -F Yellow } }

###########################
# for all mailboxes short #
###########################
$param = @{
  Identity = $MBX[$M] 
  Language = "DE-DE"
TimeFormat = "HH:mm"
DateFormat = "dd.MM.yyyy"
  TimeZone = "W. Europe Standard Time"
LocalizeDefaultFolderName = $true
   Confirm = $false }
$mbxs = get-mailbox -ResultSize unlimited
[System.Collections.ArrayList]$MBX = $mbxs.userprincipalname
for ($M = 0; $M -lt $MBX.count; $M++) { Set-MailboxRegionalConfiguration @param }
#########################