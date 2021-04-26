$Cfg = @"
Configuration\IPM.Configuration.Suite.Storage;
Configuration\IPM.Configuration.AutoComplete;
Configuration\IPM.Configuration.OWA.AutocompleteCache;
Configuration\IPM.Configuration.Agregated.OWAUserConfiguration;
Configuration\IPM.Configuration.OWA.SessionInformation;
Configuration\IPM.Configuration.OWA.UserOptions;
Configuration\IPM.Configuration.OWA.ViewStateConfiguration;
Configuration\IPM.Configuration.Relevance.SasPeopleIndexModel;
Configuration\IPM.Configuration.Relevance.SasPeopleMetadataModel;
Configuration\IPM.Configuration.Relevance.SasInstantIndexModelItem;
Configuration\IPM.Configuration.Relevance.PeopleIndexBuilderModel
"@

$Mbxs = try { get-EXOmailbox -ResultSize unlimited } catch { get-mailbox -ResultSize unlimited }
[System.Collections.ArrayList]$MBX = $mbxs | Out-Gridview -T "Select Mailboxes to Clear Cache" -P| select userprincipalname
$count= $MBX.count; $time = [system.diagnostics.stopwatch]::startNew() ; for ($M = 0; $M -lt $MBX.count ) {
$C1 = @(get-MailboxUserConfiguration -Mailbox $MBX[$M] -Identity "Configuration\*").identity
$C2  = $C1 | where { $_ -in $Cfg.Split(';') } ; Foreach ($C in $C2) {
Try { Remove-MailboxUserConfiguration -Mailbox $MBX[$M] -Identity $c -CF:$false -EA stop } catch { $Error[0].Exception | FL * -F } } 
$M++ ; $Pn = $M/$count ; $Pc = $Pn * 100 ; $Tsec = $time.ElapsedMilliseconds/1000;
$ts =  [timespan]::fromseconds($Tsec) ; $res = "$($ts.hours):$($ts.minutes):$($ts.seconds)"
$S =" [MBX] ($M/$count)  [Time/Elapsed] $res [Total]" ; $Ttl = $Tsec/$Pn ; $Tr = $Ttl - $Tsec
$A = "Clearing OWA Autocomplete Cache [Mailbox Count] ($M/$count) [Mailbox] $($MBX[$M])"
Write-Progress -Activity $A -Status $S -PercentComplete $Pc -SecondsRemaining $($count-$M) }
