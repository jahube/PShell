
#Tickling MBX -applymandatoryproperties

$mbxs = get-mailbox -ResultSize unlimited; $count= $MBXs.count
[System.Collections.ArrayList]$MBX = $mbxs.userprincipalname
for ($M = 0; $M -lt $MBX.count; $M++) { $S =" [MBX] ($($M+1)/$count)  [Time]"
$A = "Tickling Mailboxes with [applymandatoryproperties] [Mailbox Count] ($($M+1)/$count) [Mailbox] $($MBX[$M])"
Write-Progress -Activity $A -Status $S -PercentComplete (($M/$count)*100) -SecondsRemaining $($count-$M) ;
Try { Set-Mailbox -identity $MBX[$M] -applymandatoryproperties -CF:$false 
} catch { Write-Host $Error[0].Exception.Message -F Yellow } }
