#############  MODIFY ##############

$EMAIL = 'EMAIL@DOMAIN.com'

$MessageID = "<MessageID>"

$timeframe = '-4' # last 4 days

#######  $DesktopPath\MS-Logs #######
$VerbosePreference = 'Continue'
$ts = Get-Date -Format yyyyMMdd_hhmmss
$FormatEnumerationLimit = -1
$DesktopPath = ([Environment]::GetFolderPath('Desktop'))
$logsPATH =mkdir "$DesktopPath\MS-Logs\Tracking-Connector-LOG_$ts" # creates MS-Logs on desktop + Timestamp

########  Start Transcipt  ##########
Start-Transcript "$logsPATH\Tracking-Connector-LOG_$ts.txt" -Verbose

$Servers = Get-ExchangeServer;  $Servers | where {​​$_.isHubTransportServer -eq $true -or $_.isMailboxServer -eq $true}​​
$Servers | Get-MessageTrackingLog -Start (get-date).AddDays($timeframe) -End (get-date) -sender $EMAIL | Export-CsV $logsPATH\sendertrackinglog.csv
$Servers | Get-MessageTrackingLog -Start (get-date).AddDays($timeframe) -End (get-date) -Recipients $EMAIL | Export-CsV $logsPATH\receivetrackinglog.csv
IF ($MessageID -ne "<MessageID>") { $Servers | Get-MessageTrackingLog -MessageId $MessageID | Export-CsV $logsPATH\MessageID-trackinglog.csv }

Get-queue | FL > "$logsPATH\queue.txt" ; (Get-queue).LastError
Get-SendConnector | fl > "$logsPATH\SendConnector-FL.txt"
Get-ReceiveConnector | fl > "$logsPATH\ReceiveConnector-FL.txt"
Get-AuthConfig | fl > "$logsPATH\AuthConfig-FL.txt"
Get-remotedomain | FL > "$logsPATH\RemoteDomain-FL.txt"
Get-RemoteDomain |ft DomainName,IsInternal,TargetDeliveryDomain,TrustedMail*,OriginatingServer > "$logsPATH\RemoteDomain.txt"
Get-ExchangeCertificate | Format-List FriendlyName,Subject,CertificateDomains,Thumbprint,Services > "$logsPATH\certificates.txt"
$Thumbprint = (Get-AuthConfig).CurrentCertificateThumbprint ; $Thumbprint
Foreach ($i in (Get-ExchangeServer)) {Write-Host $i.FQDN; icm { Get-ExchangeCertificate -Server $i.Identity } }
Foreach ($c in (Get-ExchangeCertificate)) {Write-Host $c.Thumbprint; icm { Get-ExchangeCertificate -Thumbprint $c.Thumbprint | fl } } "$logsPATH\Certificate-FL.txt"

###### connector logs ###################

$base = "$env:ExchangeInstallPath\TransportRoles\Logs" ; $RECV = "ProtocolLog\SmtpReceive" ; $SND = "ProtocolLog\SmtpSend"
$FrontReceive = (gci "$base\FrontEnd\$RECV\")[-1].VersionInfo.filename
$HUBReceive = (gci "$base\Hub\$RECV\")[-1].VersionInfo.filename
$FrontSEND = (gci "$base\FrontEnd\$SND\")[-1].VersionInfo.filename
$HUBSEND = (gci "$base\Hub\$SND\")[-1].VersionInfo.filename
Copy-Item -Path $FrontReceive -destination $logsPATH
Copy-Item -Path $HUBReceive -destination $logsPATH
Copy-Item -Path $FrontSEND -destination $logsPATH
Copy-Item -Path $HUBSEND -destination $logsPATH

###### END TRANSCRIPT ######################
Stop-Transcript
$destination = "$DesktopPath\MS-Logs\Tracking-Connector-LOG_$ts.zip"
Add-Type -assembly “system.io.compression.filesystem”
[io.compression.zipfile]::CreateFromDirectory($logsPATH, $destination) # ZIP
Invoke-Item $DesktopPath\MS-Logs # open file manager
###### END ZIP Logs ########################


###### reference only ######################
###### Connector Logs Path (Manual) ########
# Receive connectors:
# FRONTEND  %ExchangeInstallPath%TransportRoles\Logs\FrontEnd\ProtocolLog\SmtpReceive\
# HUB       %ExchangeInstallPath%TransportRoles\Logs\Hub\ProtocolLog\SmtpReceive\
# Send connectors: 
# FRONTEND  %ExchangeInstallPath%TransportRoles\Logs\FrontEnd\ProtocolLog\SmtpSend\
# HUB       %ExchangeInstallPath%TransportRoles\Logs\Hub\ProtocolLog\SmtpSend\