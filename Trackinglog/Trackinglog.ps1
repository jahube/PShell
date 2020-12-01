

Get-ReceiveConnector | Set-ReceiveConnector -ProtocolLoggingLevel verbose
Get-SendConnector | Set-SendConnector -ProtocolLoggingLevel verbose

$sender = “affected@sender.com"
$recipient = “affected@recipient.com"
$MessageID = "<MessageID>"
$timeframe = “-5" # ("days back")

$VerbosePreference = 'Continue'
$ts = Get-Date -Format yyyyMMdd_hhmmss
$FormatEnumerationLimit = -1
$DesktopPath = ([Environment]::GetFolderPath('Desktop'))
$logsPATH =mkdir "$DesktopPath\MS-Logs\$ts" # creates MS-Logs on desktop + Timestamp
Start-Transcript "$logsPATH\OnPremises$ts.txt" -Verbose

Get-TransportService | Get-MessageTrackingLog -Start (get-date).AddDays($timeframe) -End (get-date) -sender “affected@sender.com" | Export-CsV $logsPATH\Sender-trackinglog.csv

Get-TransportService | Get-MessageTrackingLog -Start (get-date).AddDays($timeframe) -End (get-date) -Recipients “affected@recipient.com" | Export-CsV $logsPATH\Receive-trackinglog.csv

$Servers = Get-ExchangeServer;  $Servers | where {​​$_.isHubTransportServer -eq $true -or $_.isMailboxServer -eq $true}​​ | Get-MessageTrackingLog -MessageId $MessageID  | | Export-CsV $logsPATH\MessageID-trackinglog.csv

Get-queue ; (Get-queue).LastError

Get-RemoteDomain |ft DomainName,IsInternal,TargetDeliveryDomain,TrustedMail*,OriginatingServer
Get-RemoteDomain |fl
Get-SendConnector |fl
Get-ReceiveConnector | fl
Get-AuthConfig | fl
Foreach ($i in (Get-ExchangeServer)) {Write-Host $i.FQDN; Get-ExchangeCertificate -Server $i.Identity }
Foreach ($c in (Get-ExchangeCertificate)) {Write-Host $c.Thumbprint; Get-ExchangeCertificate -Thumbprint $c.Thumbprint | fl}

Stop-transcript
######END SCRIPT ##########################
# Logs >> Zip file
$destination = "$DesktopPath\MS-Logs\ConnectorLogs_$ts.zip"
Add-Type -assembly “system.io.compression.filesystem”
[io.compression.zipfile]::CreateFromDirectory($logsPATH, $destination) # ZIP
Invoke-Item $DesktopPath\MS-Logs # open file manager


