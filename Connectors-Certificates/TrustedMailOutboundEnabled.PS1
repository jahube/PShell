# the receive connector should be CREATED on EACH server created/configured/set
# credits and big thanks to Victor Legat 
############# ONPREM #####################################################################################

##############
# autodetect #
##############

Start-transcript

$R = get-remotedomain | where { $_.identity -like "Hybrid*mail.onmicrosoft*" }
$Rt = $R.name ; $Rd = $Rt -replace ".mail"

Get-remotedomain $Rt | FT Name,TrustedM*
Get-remotedomain $Rd | FT Name,TrustedM*

Set-Remotedomain $R.name -TrustedMailOutboundEnabled $true
Set-Remotedomain $Rd -TrustedMailInboundEnabled $true

Get-remotedomain $Rt | FT Name,TrustedM*
Get-remotedomain $Rd | FT Name,TrustedM*

Stop-transcript

############
# manually #
############

Start-transcript

Get-remotedomain | FL

Set-remotedomain "Hybrid Domain - YourTenantNameHere.onmicrosoft.com" -TrustedMailInboundEnabled $true

Set-remotedomain "Hybrid Domain - YourTenantNameHere.mail.onmicrosoft.com" -TrustedMailOutboundEnabled $true -TargetDeliveryDomain $true

Stop-transcript

############# EXCHANGE ONLINE ############################################################################

Set-remotedomain 'custom-domain.com' -TrustedMailOutboundEnabled $true -isinternal $true


####### ONPREM: TLS Connector Certificate steps (or HCW) #################################################

Get-ExchangeCertificate | Format-List FriendlyName,Subject,CertificateDomains,Thumbprint,Services

$TLSCert = Get-ExchangeCertificate <Thumbrint from above>

$TLSCertName = "<I>$($TLSCert.Issuer)<S>$($TLSCert.Subject)"

Set-ReceiveConnector -RequireTLS $true -TlsSettings CertificateValidation -TlsCertificateName $TLSCertName  



