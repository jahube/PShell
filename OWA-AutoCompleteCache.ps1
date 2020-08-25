# OWA-AutoCompleteCache

$CFG = "Configuration\IPM.Configuration.OWA.AutocompleteCache"
$mbxs = get-mailbox -ResultSize unlimited; $count= $MBX.count
[System.Collections.ArrayList]$MBX = $mbxs.userprincipalname
for ($M = 0; $M -lt $MBX.count; $M++) { $S =" [MBX] ($($M+1)/$count)  [Time]"
$A = "Clearing OWA Autocomplete Cache [Mailbox Count] ($($M+1)/$count) [Mailbox] $($MBX[$M])"
Write-Progress -Activity $A -Status $S -PercentComplete (($M/$count)*100) -SecondsRemaining $($count-$M) ;
Try { Remove-MailboxUserConfiguration -Mailbox $MBX[$M] -Identity $c -Confirm:$false 
} catch { Write-Host $Error[0].Exception.Message -F Yellow } }
