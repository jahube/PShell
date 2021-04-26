$mbxs = try { get-EXOmailbox -ResultSize unlimited -EA stop } catch { get-mailbox -ResultSize unlimited }
[System.Collections.ArrayList]$MBX = @($mbxs | select use*e,disp*e,Pr*ess | ogv -P -T "Select to clear Cache").userprincipalname ;
$count= $MBX.count ; for ($M = 0; $M -lt $MBX.count ) { 
$Cfg = Try { (get-MailboxUserConfiguration -Mailbox $MBX[$M] -Identity "Configuration\*" -EA stop).identity } catch {}
$C2 = $Cfg | where { $_ -match "OWA" -or $_ -match "Relevance" -or $_ -match "Search" -or $_ -match "Autocomplete" -or $_ -match "Suite.Storage" }
Foreach ( $C in $C2 ) { Remove-MailboxUserConfiguration -Mailbox $MBX[$M] -Identity $c -Confirm:$false -EA silentlycontinue }
$M++ ;  $Pc = ($M/$count) * 100 ; $A = "Clearing OWA Autocomplete Cache [Mailbox Count] [User] $($MBX[$M]) [MBX] ($M/$count)"
Write-Progress -Activity $A -Status "Remaining" -PercentComplete $Pc -SecondsRemaining $($count-$M) }