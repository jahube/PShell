# Tickle Script / All

##############################################################################

#Tickle Mailboxes -applymandatoryproperties

$MC = get-mailbox -ResultSize unlimited ; $count = $MC.count

for ($M = 0; $M -lt $MC.count;) {

Set-mailbox -identity "$(($MC[$M]).UserprincipalName)" -applymandatoryproperties -WarningAction silentlycontinue -CF:$false

$M++ ;  $S =" [Mailbox] ($M/$count)  [Time]"

$A = "Tickling Mailboxes with [applymandatoryproperties] [Mailbox Count] ($M/$count) [Mailbox] $(($MC[$M]).Name)"

Write-Progress -Activity $A -Status $S -PercentComplete (($M/$count)*100) -SecondsRemaining $($count-$M) }

##############################################################################

#Tickle Mailboxes -SimpleDisplayName

$MC = get-mailbox -ResultSize unlimited ; $count = $MC.count

for ($M = 0; $M -lt $MC.count;) {

Set-mailbox -identity "$(($MC[$M]).UserprincipalName)" -SimpleDisplayName "$(($MC[$M]).SimpleDisplayName)" -WarningAction silentlycontinue -CF:$false

$M++ ;  $S =" [Mailbox] ($M/$count)  [Time]"

$A = "Tickling Mailboxes with [SimpleDisplayName] [Mailbox Count] ($M/$count) [Mailbox] $(($MC[$M]).Name) / $(($MC[$M]).SimpleDisplayName) "

Write-Progress -Activity $A -Status $S -PercentComplete (($M/$count)*100) -SecondsRemaining $($count-$M) }

##############################################################################

#Tickle Mailusers -SimpleDisplayName

$MU = get-Mailuser -ResultSize unlimited ; $count = $MU.count

for ($M = 0; $M -lt $MU.count;) {

Set-Mailuser -identity "$(($MU[$M]).UserprincipalName)" -SimpleDisplayName "$(($MU[$M]).SimpleDisplayName)" -WarningAction silentlycontinue -CF:$false

$M++ ;  $S =" [Mailuser] ($M/$count)  [Time]"

$A = "Tickling Mailusers with [SimpleDisplayName] [Mailuser Count] ($M/$count) [Mailuser] $(($MU[$M]).Name) / $(($MU[$M]).SimpleDisplayName) "

Write-Progress -Activity $A -Status $S -PercentComplete (($M/$count)*100) -SecondsRemaining $($count-$M) }

##############################################################################

#Tickle MailContacts -CustomAttribute15 "test"

$MC = get-MailContact -ResultSize unlimited ; $count = $MC.count

for ($M = 0; $M -lt $MC.count;) {

Set-MailContact -identity "$(($MC[$M]).PrimarySmtpAddress)" -CustomAttribute15 "test" -WarningAction silentlycontinue -CF:$false

$M++ ;  $S =" [Contact] ($M/$count)  [Time]"

$A = "Tickling Contacts with [CustomAttribute15] [Contacts Count] ($M/$count) [Contact] $(($MC[$M]).PrimarySmtpAddress)"

Write-Progress -Activity $A -Status $S -PercentComplete (($M/$count)*100) -SecondsRemaining $($count-$M) }

##############################################################################

#Tickle O365 Groups -CustomAttribute15 "test"

$GRP = Get-UnifiedGroup -ResultSize unlimited ; $count = $GRP.count

for ($M = 0; $M -lt $GRP.count;) {

Set-UnifiedGroup -identity "$(($GRP[$M]).Name)" -CustomAttribute15 "test" -WarningAction silentlycontinue -CF:$false

$M++ ;  $S =" [Group] ($M/$count)  [Time]"

$A = "Tickling O365 Groups with [CustomAttribute15] [Group Count] ($M/$count) [Group] $(($GRP[$M]).Name)"

Write-Progress -Activity $A -Status $S -PercentComplete (($M/$count)*100) -SecondsRemaining $($count-$M) }

##############################################################################

#Tickle DistributionGroups -CustomAttribute15 "test"

$DL = Get-DistributionGroup -ResultSize unlimited ; $count = $DL.count

for ($M = 0; $M -lt $DL.count;) {

Set-DistributionGroup -identity "$(($DL[$M]).Name)" -CustomAttribute15 "test" -WarningAction silentlycontinue -CF:$false

$M++ ;  $S =" [DL] ($M/$count)  [Time]"

$A = "Tickling DLs with [CustomAttribute15] [DL Count] ($M/$count) [DL] $(($DL[$M]).Name)"

Write-Progress -Activity $A -Status $S -PercentComplete (($M/$count)*100) -SecondsRemaining $($count-$M) }

##############################################################################

#Tickle DistributionGroups -SimpleDisplayName

$DL = Get-DistributionGroup -ResultSize unlimited ; $count = $DL.count

for ($M = 0; $M -lt $DL.count;) {

Set-DistributionGroup -identity "$(($DL[$M]).Name)" -SimpleDisplayName "$(($DL[$M]).SimpleDisplayName)" -WarningAction silentlycontinue -CF:$false

$M++ ;  $S =" [DL] ($M/$count)  [Time]"

$A = "Tickling DLs with [SimpleDisplayName] [DL Count] ($M/$count) [DL] $(($MC[$M]).Name) / $(($MC[$M]).SimpleDisplayName)"

Write-Progress -Activity $A -Status $S -PercentComplete (($M/$count)*100) -SecondsRemaining $($count-$M) }