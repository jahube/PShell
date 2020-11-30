$sender = “affected@sender.com"
$recipient = “affected@recipient.com"

$VerbosePreference = 'Continue'
$ts = Get-Date -Format yyyyMMdd_hhmmss
$FormatEnumerationLimit = -1
$DesktopPath = ([Environment]::GetFolderPath('Desktop'))
$logsPATH =mkdir "$DesktopPath\MS-Logs\$ts" # creates MS-Logs on desktop + Timestamp
Start-Transcript "$logsPATH\OnPremises$ts.txt" -Verbose

Get-TransportService | Get-MessageTrackingLog -Start (get-date).AddDays(-15) -End (get-date) -sender “affected@sender.com" | Export-CsV $logsPATH\sendertrackinglog2.csv

Get-TransportService | Get-MessageTrackingLog -Start (get-date).AddDays(-15) -End (get-date) -Recipients “affected@recipient.com" | Export-CsV $logsPATH\receivetrackinglog2.csv

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


