# NEW - MBX stats all users
$mbxs = Get-Mailbox -ResultSize Unlimited 
[System.Collections.ArrayList]$MBX = $mbxs.userprincipalname ; $DATA = @()
for ($M = 0; $M -lt $MBX.count; $M++) { $S =" [MBX] ($($M+1)/$count)  [Time]"
$A = "collecting stats [Mailbox Count] ($($M+1)/$count) [Mailbox] $($MBX[$M])"
Write-Progress -Activity $A -Status $S -PercentComplete (($M/$count)*100) -SecondsRemaining ($count-$M) ;
$mbxstats = icm { Get-MailboxStatistics $($MBX[$M]) } ; $DATA += $mbxstats }
$DATA | Select DisplayName,StorageLimitStatus, `
@{name=”TotalItemSize (MB)”; expression={[math]::Round( `
($_.TotalItemSize.ToString().Split(“(“)[1].Split(” “)[0].Replace(“,”,””)/1MB),2)}}, `
ItemCount | Sort “TotalItemSize (MB)” -Descending


# OLD - MBX stats all users
$mbx = Get-Mailbox -ResultSize Unlimited 
$stats = Foreach ($m in $mbx.distinguishedname) { icm { Get-MailboxStatistics $m } }
$stats | Select DisplayName,StorageLimitStatus, `
@{name=”TotalItemSize (MB)”; expression={[math]::Round( `
($_.TotalItemSize.ToString().Split(“(“)[1].Split(” “)[0].Replace(“,”,””)/1MB),2)}}, `
ItemCount | Sort “TotalItemSize (MB)” -Descending