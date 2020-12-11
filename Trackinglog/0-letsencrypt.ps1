Install-Module -Name Posh-ACME
 
$certNames = 'domain.com','*.domain.com'
 
New-PACertificate $certNames -AcceptTOS -Contact admin@domain.com -DnsPlugin AcmeDns -PluginArgs @{ACMEServer='auth.acme-dns.io'} -Install -FriendlyName 'domain.com' -PreferredChain "ISRG Root X2" -Force