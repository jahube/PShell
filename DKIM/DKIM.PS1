$Domain = "edu.dnsabr.com"
$tenant = "M365EDU471782.onmicrosoft.com" # "YourTenant.onmicrosoft.com"
$host1 = "Selector1._domainkey." ; $host2 = "Selector2._domainkey."
$Value = $Domain -replace "\.","-" ; $hostname1 =  $host1 + $domain; $hostname2 =  $host2 + $domain
$Selector1 = "selector1-" + $Value + "._domainkey." + $tenant
$Selector2 = "selector2-" + $Value + "._domainkey." + $tenant
$DKIM1 = (Resolve-DnsName "$hostname1" CNAME -DnsOnly).namehost
$DKIM2 = (Resolve-DnsName "$hostname2" CNAME -DnsOnly).namehost

 

Write-host "`n`n     CNAME Selector 1" -F yellow  ; Write-host "-----------------------------------" -F green
Write-host "[Host name 1] " -F white -NoNewline ; Write-host "  $Host1" -F yellow -NoNewline ; Write-host $Domain -F green
Write-host "[Points To  ]  " -F white -NoNewline
Write-host " selector1-" -F yellow -NoNewline ; Write-host "$Value" -F cyan -NoNewline
Write-host "._domainkey." -F yellow -NoNewline ; Write-host $tenant -F green

 

Write-host "[Existing DKIM CNAME ]  " -F green -NoNewline
If ($DKIM1) { Write-host "$DKIM1" -F yellow -NoNewline }
If ($DKIM1 -eq $Selector1) { Write-host "   [ OK ]" -F green -NoNewline }
If (($DKIM1) -and ($DKIM1 -ne $Selector1)) { Write-host "   [ INCORRECT ]" -F cyan -NoNewline }
Write-host "`n`n     CNAME Selector 2" -F yellow  ; Write-host "-----------------------------------" -F green
Write-host "[Host name 2] " -F white -NoNewline ; Write-host "  $Host2" -F yellow -NoNewline ; Write-host $Domain -F green
Write-host "[Points To  ]  " -F white -NoNewline
Write-host " selector1-" -F yellow -NoNewline ; Write-host "$Value" -F cyan -NoNewline
Write-host "._domainkey." -F yellow -NoNewline ; Write-host $tenant -F green

 

Write-host "[Existing DKIM CNAME ]  " -F green -NoNewline
If ($DKIM2) { Write-host "$DKIM2" -F yellow -NoNewline }
If ($DKIM2 -eq $Selector2) { Write-host "   [ OK ]" -F green -NoNewline }
If (($DKIM2) -and ($DKIM2 -ne $Selector2)) { Write-host "   [ INCORRECT ]" -F cyan -NoNewline }