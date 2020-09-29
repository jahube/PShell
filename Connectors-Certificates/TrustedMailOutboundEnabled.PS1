
############# ONPREM #####################################################################################

Start-transcript

Get-remotedomain | FL

Set-remotedomain 'tenant.onmicrosoft.com' -TrustedMailnboundEnabled $true

Set-remotedomain 'tenant.mail.onmicrosoft.com' -TrustedMailOutboundEnabled $true -TargetDeliveryDomain $true

Stop-transcript



Get-ExchangeCertificate | Format-List FriendlyName,Subject,CertificateDomains,Thumbprint,Services


** the receive connector should be CREATED on EACH server created/configured/set ** THANKS VICTOR !


$TLSCert = Get-ExchangeCertificate <Thumbrint from above>

$TLSCertName = "<I>$($TLSCert.Issuer)<S>$($TLSCert.Subject)"

Set-ReceiveConnector -RequireTLS $true -TlsSettings CertificateValidation -TlsCertificateName $TLSCertName  


############# EXCHANGE ONLINE ############################################################################

Set-remotedomain 'custom-domain.com' -TrustedMailOutboundEnabled $true -isinternal $true


