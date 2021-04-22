# Fix/update commercial certificate

Get-ExchangeCertificate | Format-List FriendlyName,Subject,CertificateDomains,Thumbprint,Services

enable-ExchangeCertificate -Thumbprint YourThumbprintCODE -Services POP,IMAP,IIS,SMTP

# Set the certificate to be used for server authentication by running the following commands:

Set-AuthConfig -NewCertificateThumbprint YourThumbprintCODE -NewCertificateEffectiveDate  (Get-Date)

Set-AuthConfig -PublishCertificate

Set-AuthConfig -ClearPreviousCertificate

# IIS reset has 1 minute downtime at least
IISReset 

Restart-WebAppPool MSExchangeOWAAppPool
Restart-WebAppPool MSExchangeECPAppPool
