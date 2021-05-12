# Tickle Script / All

##############################################################################

#Tickle Mailboxes -applymandatoryproperties

$mbxs = get-mailbox -ResultSize unlimited; $count= $MBXs.count
[System.Collections.ArrayList]$MBX = $mbxs.userprincipalname
for ($M = 0; $M -lt $MBX.count; $M++) { $S =" [MBX] ($($M+1)/$count)  [Time]"
$A = "Tickling Mailboxes with [applymandatoryproperties] [Mailbox Count] ($($M+1)/$count) [Mailbox] $($MBX[$M])"
Write-Progress -Activity $A -Status $S -PercentComplete (($M/$count)*100) -SecondsRemaining $($count-$M) ;
Try { Set-Mailbox -identity $MBX[$M] -applymandatoryproperties -WarningAction silentlycontinue -EA stop -CF:$false 
} catch { Write-Host $Error[0].Exception.Message -F Yellow } }

##############################################################################

#Tickle MailContacts -CustomAttribute15 "test"

$MCs = get-MailContact -ResultSize unlimited ; $count = $MCs.count

[System.Collections.ArrayList]$MC = $MCs.PrimarySmtpAddress

for ($M = 0; $M -lt $MC.count;) {

Set-MailContact -identity $MC[$M] -CustomAttribute15 "test" -WarningAction silentlycontinue -CF:$false

$M++ ;  $S =" [Contact] ($M/$count)  [Time]"

$A = "Tickling Contacts with [applymandatoryproperties] [Contacts Count] ($M/$count) [Contact] $($MC[$M])"

Write-Progress -Activity $A -Status $S -PercentComplete (($M/$count)*100) -SecondsRemaining $($count-$M) }

##############################################################################

#Tickle O365 Groups -CustomAttribute15 "test"

$GRPs = Get-UnifiedGroup -ResultSize unlimited 

[System.Collections.ArrayList]$GRP = $GRPs.Name ; $count = $GRP.count

for ($M = 0; $M -lt $GRP.count;) {

Set-UnifiedGroup -identity $GRP[$M] -CustomAttribute15 "test" -WarningAction silentlycontinue -CF:$false

$M++ ;  $S =" [Group] ($M/$count)  [Time]"

$A = "Tickling O365 Groups with [CustomAttribute15] [Group Count] ($M/$count) [Group] $($GRP[$M])"

Write-Progress -Activity $A -Status $S -PercentComplete (($M/$count)*100) -SecondsRemaining $($count-$M) }

##############################################################################

#Tickle DistributionGroups -CustomAttribute15 "test"

$DLs = Get-DistributionGroup -ResultSize unlimited ; $count = $DLs.count

[System.Collections.ArrayList]$DL = $DLs.Name

for ($M = 0; $M -lt $DL.count;) {

Set-DistributionGroup -identity $DL[$M] -CustomAttribute15 "test" -WarningAction silentlycontinue -CF:$false

$M++ ;  $S =" [DL] ($M/$count)  [Time]"

$A = "Tickling DLs with [CustomAttribute15] [DL Count] ($M/$count) [DL] $($DL[$M])"

Write-Progress -Activity $A -Status $S -PercentComplete (($M/$count)*100) -SecondsRemaining $($count-$M) }