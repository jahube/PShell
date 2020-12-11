
#######  $DesktopPath\MS-Logs #######

$VerbosePreference = 'Continue'
$ts = Get-Date -Format yyyyMMdd_hhmmss
$FormatEnumerationLimit = -1
$DesktopPath = ([Environment]::GetFolderPath('Desktop'))
$logsPATH =mkdir "$DesktopPath\MS-Logs\SET-Connector_$ts" # creates MS-Logs on desktop + Timestamp

########  Start Transcipt  ##########

Start-Transcript "$logsPATH\SET-Connector_$ts.txt" -Verbose

Get-SendConnector | fl > "$logsPATH\SendConnector-FL-before.txt"
Get-ReceiveConnector | fl > "$logsPATH\ReceiveConnector-FL-before.txt"

#SET connector Logging Verbose
Get-ReceiveConnector | Set-ReceiveConnector -ProtocolLoggingLevel verbose
Get-SendConnector | Set-SendConnector -ProtocolLoggingLevel verbose

Get-ExchangeCertificate | Format-List FriendlyName,Subject,CertificateDomains,Thumbprint,Services > "$logsPATH\certificates.txt"

# specify thumbprint  for connector or chose default from Authconfig
# $Thumbprint = "code from above"
$Thumbprint = (Get-AuthConfig).CurrentCertificateThumbprint ; $Thumbprint

# CertificateName "<I>issuer<S>subject" from certificate
$TLSCert=Get-ExchangeCertificate -Thumbprint $Thumbprint
$TLSCertName="<I>$($TLScert.Issuer)<S>$($TLSCert.Subject)" ; $Exch = $(get-exchangeserver).name

#SET Receiveconnector
Get-ReceiveConnector "$Exch\Default Frontend $Exch" | Set-ReceiveConnector -TlsCertificateName $TLSCertName

#SET Sendconnector
Set-SendConnector -Identity "Outbound to Office 365*" -TLSCertificateName $TLSCertName -ProtocolLoggingLevel verbose

Get-SendConnector | fl > "$logsPATH\SendConnector-FL-After.txt"
Get-ReceiveConnector | fl > "$logsPATH\ReceiveConnector-FL-After.txt"

Get-AuthConfig | fl > "$logsPATH\AuthConfig-FL.txt"

Foreach ($i in (Get-ExchangeServer)) {Write-Host $i.FQDN; icm { Get-ExchangeCertificate -Server $i.Identity } }

Foreach ($c in (Get-ExchangeCertificate)) {Write-Host $c.Thumbprint; icm { Get-ExchangeCertificate -Thumbprint $c.Thumbprint | fl } } "$logsPATH\Certificate-FL.txt"

Stop-Transcript

###### END TRANSCRIPT ######################

$destination = "$DesktopPath\MS-Logs\SET-Connector_$ts.zip"
Add-Type -assembly “system.io.compression.filesystem”
[io.compression.zipfile]::CreateFromDirectory($logsPATH, $destination) # ZIP
Invoke-Item $DesktopPath\MS-Logs # open file manager

###### END ZIP Logs ########################