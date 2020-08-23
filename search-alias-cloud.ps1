$v = 'search string here'
$M = Get-Mailbox -IncludeInactiveMailbox -ResultSize unlimited
$R=$M|?{$_.EmailAddresses -match $v -or $_.WindowsLiveID -match $v -or $_.LegacyExchangeDN -match $v -or $_.WindowsEmailAddress -match $v } 
if ($R){ Write-host $R.userprincipalname -F yellow -NoNewline ; Write-host " Mailbox" -F green }
$users = Get-Msoluser -all
$found=$users | ?{$_.UserPrincipalName -match $v -or $_.ProxyAddresses -match $v }
if ($found) { Write-host $found.userprincipalname -F green -NoNewline ; Write-host " [Active User]" -F green}
$S = Get-Msoluser -returndeletedusers -all
$Del = $S | ?{$_.UserPrincipalName -match $v -or $_.ProxyAddresses -match $v }
if ($Del) { Write-host $Del.userprincipalname -F yellow -NoNewline; Write-host " [Deleted User]" -F cyan }