# PS 7 only

install-module Splitpipeline
import-module Splitpipeline

$mailbox = get-mailbox -ResultSize unlimited

[System.Collections.ArrayList]$mailboxDist = $mailbox.distinguishedname
[System.Collections.ArrayList]$mailboxSAM = $mailbox.samaccountname
[System.Collections.ArrayList]$mailboxGUID = $mailbox.guid
[System.Collections.ArrayList]$mailboxEXO = $mailbox.exchangeguid
[System.Collections.ArrayList]$mailboxUPN = $mailbox.userprincipalname
[System.Collections.ArrayList]$mailboxAlias = $mailbox.alias
$n = $env:NUMBER_OF_PROCESSORS
$Dist = {​ for ($F = 0; $F -lt $mailboxDist.count; $F++) {​ Get-Mailbox $mailboxDist[$F] }​ }​
$SAM = {​ for ($F = 0; $F -lt $mailboxSAM.count; $F++) {​ Get-Mailbox $mailboxSAM[$F]  }​ }​
$GUID = {​ for ($F = 0; $F -lt $mailboxGUID.count; $F++) {​ Get-Mailbox $mailboxGUID[$F]  }​ }​
$EXO = {​ for ($F = 0; $F -lt $mailboxEXO.count; $F++) {​ Get-Mailbox $mailboxEXO[$F]  }​ }​
$UPN = {​ for ($F = 0; $F -lt $mailboxUPN.count; $F++) {​ Get-Mailbox $mailboxUPN[$F]  }​ }​
$ALIAS = {​ for ($F = 0; $F -lt $mailboxAlias.count; $F++) {​ Get-Mailbox $mailboxAlias[$F]  }​ }​
$SplitPipeline = {​
    Connect-ExchangeOnline -UserPrincipalName admin@edu.dnsabr.com
    $mailbox = get-mailbox -ResultSize unlimited
    $mailbox | Split-Pipeline {​ process {​ Get-Mailbox $_.userprincipalname }​ }​ -Count $n
}​
$ForEachObject = {​
 Connect-ExchangeOnline -UserPrincipalName admin@edu.dnsabr.com
 $mailbox = get-mailbox -ResultSize unlimited
 $mailbox | ForEach-Object -Parallel {​ Get-Mailbox $_.userprincipalname }​ -ThrottleLimit $n
}​
$ForEach = {​
    foreach ($m in $mailbox) {​ Get-Mailbox $m.distinguishedname }​
}​
#"SplitPipeline $((Measure-Command $SplitPipeline).TotalMilliseconds)"
#"ForEachObject $((Measure-Command $ForEachObject).TotalMilliseconds)"
"ForEach $((Measure-Command $ForEach).TotalMilliseconds)"
"Dist $((Measure-Command $Dist).TotalMilliseconds)"
"SAM $((Measure-Command $SAM).TotalMilliseconds)"
"GUID $((Measure-Command $GUID).TotalMilliseconds)"
"EXO $((Measure-Command $EXO).TotalMilliseconds)"
"UPN $((Measure-Command $UPN).TotalMilliseconds)"
"ALIAS $((Measure-Command $ALIAS).TotalMilliseconds)"
# Get-PSSession | Remove-PSSession
Connect-ExchangeOnline -UserPrincipalName admin@edu.dnsabr.com
$mailbox | Split-Pipeline {​ process {​ Get-Mailbox $_.userprincipalname }​ }​ -Count $n
$starttime1 = [system.diagnostics.stopwatch]::StartNew() class and issue the startNew()
$mailbox | Split-Pipeline {​ process {​ Get-Mailbox $_.userprincipalname }​ }​ -Count $n
$starttime1.stop()
$starttime1.elapsed
$starttime2 = [system.diagnostics.stopwatch]::StartNew()
$mailbox | ForEach-Object -Parallel {​ Get-Mailbox $_.userprincipalname }​ -ThrottleLimit $n
$starttime2.stop()
$starttime2.elapsed
$starttime2 = [system.diagnostics.stopwatch]::StartNew()
$mailbox | ForEach-Object {​ Get-Mailbox $_.userprincipalname }​
$starttime2.stop()
$starttime2.elapsed
    
    
  
  

