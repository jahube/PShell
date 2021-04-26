$mbxs = try { get-EXOmailbox -ResultSize unlimited -EA stop } catch { get-mailbox -ResultSize unlimited }
[System.Collections.ArrayList]$MBX = $mbxs.userprincipalname ; $count= $MBX.count

        $time = [system.diagnostics.stopwatch]::startNew() ; for ($M = 0; $M -lt $MBX.count ) {
    try { $C1 = @(get-MailboxUserConfiguration -Mailbox $MBX[$M] -Identity "Configuration\*" -EA stop).identity }
  catch {        $Error[0].Exception | FL * -F }
         $C2  =  $C1 | where { $_ -match "OWA" -or $_ -match "Relevance" -or $_ -match "Search" -or $_ -match "Autocomplete" -or $_ -match "Suite.Storage" }
       
Foreach ( $C in $C2 ) { Remove-MailboxUserConfiguration -Mailbox $MBX[$M] -Identity $c -Confirm:$false -EA silentlycontinue }

  $M++ ;  $Pn = $M/$count ; $Pc = $Pn * 100 ;
        $Tsec = $time.ElapsedMilliseconds/1000 ;
          $ts =  [timespan]::fromseconds($Tsec) ;
         $res = "$($ts.hours):$($ts.minutes):$($ts.seconds)"
           $S = "[Time/Elapsed] $res [Total]" ; $Ttl = $Tsec/$Pn ; $Tr = $Ttl - $Tsec
           $A = "Clearing OWA Autocomplete Cache [Mailbox Count] [User] $($MBX[$M]) [MBX] ($M/$count)  "

Write-Progress -Activity $A -Status $S -PercentComplete $Pc -SecondsRemaining $($count-$M) }