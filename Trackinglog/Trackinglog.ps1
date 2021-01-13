
Get-ReceiveConnector | Set-ReceiveConnector -ProtocolLoggingLevel verbose
Get-SendConnector | Set-SendConnector -ProtocolLoggingLevel verbose

$EMAIL = 'EMAIL@DOMAIN.com'

$MessageID = "<MessageID>"

$timeframe = “-5" # ("days back")

$VerbosePreference = 'Continue'
$ts = Get-Date -Format yyyyMMdd_hhmmss
$FormatEnumerationLimit = -1
$DesktopPath = ([Environment]::GetFolderPath('Desktop'))
$logsPATH =mkdir "$DesktopPath\MS-Logs\$ts" # creates MS-Logs on desktop + Timestamp
Start-Transcript "$logsPATH\OnPremises$ts.txt" -Verbose

$Servers = Get-ExchangeServer;  $Servers | where {​​$_.isHubTransportServer -eq $true -or $_.isMailboxServer -eq $true}​​

$senderlog = $Servers | Get-MessageTrackingLog -Start (get-date).AddDays($timeframe) -End (get-date) -sender $EMAIL 
$senderlog | Export-CsV $logsPATH\Sender-trackinglog.csv -notypeinformation
$senderlog | Export-clixml -path $logsPATH\Sender-trackinglog.xml

$Recipientlog = $Servers | Get-MessageTrackingLog -Start (get-date).AddDays($timeframe) -End (get-date) -Recipients $EMAIL 
$Recipientlog | Export-CsV $logsPATH\Receive-trackinglog.csv -notypeinformation
$Recipientlog | Export-clixml -path $logsPATH\Receive-trackinglog.xml


$MessageIDLog = $Servers | Get-MessageTrackingLog -MessageId $MessageID
$MessageIDLog | Export-CsV $logsPATH\MessageID-trackinglog.csv -notypeinformation
$MessageIDLog | Export-clixml -path $logsPATH\MessageID-trackinglog.xml

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


