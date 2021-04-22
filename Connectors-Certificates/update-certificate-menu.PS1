# Fix/update commercial certificate

Get-ExchangeCertificate | Format-List FriendlyName,Subject,CertificateDomains,Thumbprint,Services 

$cert = Get-ExchangeCertificate | Format-List FriendlyName,Subject,CertificateDomains,Thumbprint,Services | Out-Gridview -T "Select Certificate to activate" -OutputMode single

$cert | Format-List FriendlyName,Subject,CertificateDomains,Thumbprint,Services

enable-ExchangeCertificate -Thumbprint $cert.Thumbprint -Services POP,IMAP,IIS,SMTP

Set-AuthConfig -NewCertificateThumbprint $cert.Thumbprint -NewCertificateEffectiveDate  (Get-Date)

Set-AuthConfig -PublishCertificate

Set-AuthConfig -ClearPreviousCertificate

# IIS reset has 1 minute downtime at least

IISReset 

Restart-WebAppPool MSExchangeOWAAppPool
Restart-WebAppPool MSExchangeECPAppPool
