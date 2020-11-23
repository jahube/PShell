install-module ExchangeOnlinemanagement

Connect-ExchangeOnline -UserPrincipalName "admin@DOMAIN.com"

OPTION 1 
manual 1 FILE per Queue   
# OR see Auto Queue Parse

# Queue 1
#############################################################################

$HelpDesk1 = $CSVqueue = Import-Csv C:\queue1.csv  # CSV Version # MODIFY FILE

$Qusers = $HelpDesk1  ;  $qname = 'HelpDesk1' # MODIFY BOTH

#############################################################################
$cnt2 = $Qusers.count ; $B = "[Adding Custom Tag for Mailbox:]"
for ($U = 0; $U -lt $cnt2; $U++) { $S2 = " - [ $($Qusers[$U].primarysmtpaddress) ]"
Write-Progress -Id 1 -Activity $B -Status $S2 -PercentComplete $(($U/$cnt2)*100) -SecondsRemaining $($cnt2-$U) ;
set-mailbox -Identity $($Qusers[$U].userguid) -CustomAttribute12 $qname   }
#############################################################################

# Queue 2
#############################################################################

$HelpDesk1 = $CSVqueue = Import-Csv C:\queue2.csv # CSV Version # MODIFY FILE

$Qusers = $HelpDesk2  ;  $qname = 'HelpDesk2' # MODIFY BOTH

#############################################################################
$cnt2 = $Qusers.count ; $B = "[Adding Custom Tag for Mailbox:]"
for ($U = 0; $U -lt $cnt2; $U++) { $S2 = " - [ $($Qusers[$U].primarysmtpaddress) ]"
Write-Progress -Id 1 -Activity $B -Status $S2 -PercentComplete $(($U/$cnt2)*100) -SecondsRemaining $($cnt2-$U) ;
set-mailbox -Identity $($Qusers[$U].userguid) -CustomAttribute12 $qname   }
#############################################################################

continue same patter for more