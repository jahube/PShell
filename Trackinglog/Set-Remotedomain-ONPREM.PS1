#######  $DesktopPath\MS-Logs #######
$VerbosePreference = 'Continue'
$ts = Get-Date -Format yyyyMMdd_hhmmss
$FormatEnumerationLimit = -1
$DesktopPath = ([Environment]::GetFolderPath('Desktop'))
$logsPATH =mkdir "$DesktopPath\MS-Logs\SET-REMOTEDOMAIN_$ts" # creates MS-Logs on desktop + Timestamp

########  Start Transcipt  ##########
Start-Transcript "$logsPATH\SET-REMOTEDOMAIN_$ts.txt" -Verbose

#get before
Get-RemoteDomain |ft DomainName,IsInternal,TargetDeliveryDomain,TrustedMail*,OriginatingServer > "$logsPATH\RemoteDomain-before.txt"
Get-remotedomain | FL > "$logsPATH\RemoteDomain-FL-before.txt"

#catch remote routing domains
$remoterouting = (Get-Remotedomain).name | ? {$_ -match '.mail.onmicrosoft.com'} 
$tenantdomain = $remoterouting -replace '.mail' ; $remoterouting ; $tenantdomain

# SET TRUSTED-INBOUND/OUTBOUND
Set-remotedomain $tenantdomain -TrustedMailInboundEnabled $true
Set-remotedomain $remoterouting -TrustedMailOutboundEnabled $true -TargetDeliveryDomain $true

#get after
Get-remotedomain | FL > "$logsPATH\RemoteDomain-FL-after.txt"
Get-RemoteDomain |ft DomainName,IsInternal,TargetDeliveryDomain,TrustedMail*,OriginatingServer > "$logsPATH\RemoteDomain-after.txt"

#connectors
Get-SendConnector | fl > "$logsPATH\SendConnector-FL-After.txt"
Get-ReceiveConnector | fl > "$logsPATH\ReceiveConnector-FL-After.txt"

# certificate / Authconfig
Get-AuthConfig | fl > "$logsPATH\AuthConfig-FL.txt"
Get-ExchangeCertificate | Format-List FriendlyName,Subject,CertificateDomains,Thumbprint,Services > "$logsPATH\certificates.txt"
$Thumbprint = (Get-AuthConfig).CurrentCertificateThumbprint ; $Thumbprint
Foreach ($i in (Get-ExchangeServer)) {Write-Host $i.FQDN; icm { Get-ExchangeCertificate -Server $i.Identity } }
Foreach ($c in (Get-ExchangeCertificate)) {Write-Host $c.Thumbprint; icm { Get-ExchangeCertificate -Thumbprint $c.Thumbprint | fl } } "$logsPATH\Certificate-FL.txt"

###### END TRANSCRIPT ######################
Stop-Transcript
$destination = "$DesktopPath\MS-Logs\SET-REMOTEDOMAIN_$ts.zip"
Add-Type -assembly “system.io.compression.filesystem”
[io.compression.zipfile]::CreateFromDirectory($logsPATH, $destination) # ZIP
Invoke-Item $DesktopPath\MS-Logs # open file manager
###### END ZIP Logs ########################

