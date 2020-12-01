#############  MODIFY ##############

$sender = 'affected@sender.com'
$recipient = 'affected@recipient.com'
$timeframe = '-4'

#######  $DesktopPath\MS-Logs #######

$ts = Get-Date -Format yyyyMMdd_hhmmss
$FormatEnumerationLimit = -1
$DesktopPath = ([Environment]::GetFolderPath('Desktop'))
$logsPATH =mkdir "$DesktopPath\MS-Logs\ConnectorLogs_$ts" # creates MS-Logs on desktop + Timestamp

########  Start Transcipt  ##########

Start-Transcript "$logsPATH\ConnectorLogs_$ts.txt" -Verbose

Get-RemoteDomain |ft DomainName,IsInternal,TargetDeliveryDomain,TrustedMail*,OriginatingServer > "$logsPATH\RemoteDomain-before.txt"

Get-ExchangeCertificate | Format-List FriendlyName,Subject,CertificateDomains,Thumbprint,Services > "$logsPATH\certificates.txt"
# $Thumbprint = "code from above"

$Thumbprint = (Get-AuthConfig).CurrentCertificateThumbprint ; $Thumbprint
$TLSCert=Get-ExchangeCertificate -Thumbprint $Thumbprint
$TLSCertName="<I>$($TLScert.Issuer)<S>$($TLSCert.Subject)" ; $Exch = $(get-exchangeserver).name

Get-ReceiveConnector "$Exch\Default Frontend $Exch" | Set-ReceiveConnector -TlsCertificateName $TLSCertName

Set-SendConnector -Identity "Outbound to Office 365*" -TLSCertificateName $TLSCertName -ProtocolLoggingLevel verbose

Get-ReceiveConnector | Set-ReceiveConnector -ProtocolLoggingLevel verbose

Set-SendConnector | Set-SendConnector -ProtocolLoggingLevel verbose

# Restart-Service MSExchangeTransport

$remoterouting = (Get-Remotedomain).name | ? {$_ -match '.mail.onmicrosoft.com'} 
$tenantdomain = $remoterouting -replace '.mail' ; $remoterouting ; $tenantdomain

Set-remotedomain $tenantdomain -TrustedMailInboundEnabled $true

Set-remotedomain $remoterouting -TrustedMailOutboundEnabled $true -TargetDeliveryDomain $true

Get-remotedomain | FL > "$logsPATH\RemoteDomain-FL.txt"
Get-RemoteDomain |ft DomainName,IsInternal,TargetDeliveryDomain,TrustedMail*,OriginatingServer > "$logsPATH\RemoteDomain-after.txt"

Get-TransportService | icm { Get-MessageTrackingLog -Start (get-date).AddDays($timeframe) -End (get-date) -sender $sender | Export-CsV $logsPATH\sendertrackinglog.csv  }
Get-TransportService | icm { Get-MessageTrackingLog -Start (get-date).AddDays($timeframe) -End (get-date) -Recipients $recipient | Export-CsV $logsPATH\receivetrackinglog.csv  }

Get-SendConnector | fl > "$logsPATH\SendConnector-FL.txt"
Get-ReceiveConnector | fl > "$logsPATH\ReceiveConnector-FL.txt"
Get-AuthConfig | fl > "$logsPATH\AuthConfig-FL.txt"

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

Stop-Transcript

###### END TRANSCRIPT ######################

$destination = "$DesktopPath\MS-Logs\ConnectorLogs_$ts.zip"
Add-Type -assembly “system.io.compression.filesystem”
[io.compression.zipfile]::CreateFromDirectory($logsPATH, $destination) # ZIP
Invoke-Item $DesktopPath\MS-Logs # open file manager

###### END ZIP Logs ########################


###### Connector Logs Path (Manual) ########
# Receive connectors:
# FRONTEND  %ExchangeInstallPath%TransportRoles\Logs\FrontEnd\ProtocolLog\SmtpReceive\
# HUB       %ExchangeInstallPath%TransportRoles\Logs\Hub\ProtocolLog\SmtpReceive\
# Send connectors: 
# FRONTEND  %ExchangeInstallPath%TransportRoles\Logs\FrontEnd\ProtocolLog\SmtpSend\
# HUB       %ExchangeInstallPath%TransportRoles\Logs\Hub\ProtocolLog\SmtpSend\