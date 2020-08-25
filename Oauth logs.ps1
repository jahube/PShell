NOTE: $CloudMailbox should be a REMOTE-Mailbox / migrated (synced with onprem) - Thank You !

OnPremises Exchange Management Shell:
-----------------------------------

$OnpremMailbox = "synced@OnPremUser.com"
$CloudMailbox = "migrated@CloudUser.com" # REMOTE-Mailbox / migrated (synced with onprem) - Thank You !
$ExchangeServer = "<Hybrid Server>"

$VerbosePreference = 'Continue'
$ts = Get-Date -Format yyyyMMdd_hhmmss
$FormatEnumerationLimit = -1
Start-Transcript OnPremises$ts.txt -verbose

Get-MapiVirtualDirectory | FL server,*url*,*auth*
Get-WebServicesVirtualDirectory | FL server,*url*,*oauth*
Get-OABVirtualDirectory | FL server,*url*,*oauth*
Get-AutoDiscoverVirtualDirectory | FL server,*oauth*
Get-ClientAccessServer | fl *uri

Get-AuthServer | fl
Get-PartnerApplication | fl
Get-PartnerApplication 00000002-0000-0ff1-ce00-000000000000 | Select-Object -ExpandProperty LinkedAccount | Get-User |fl
Get-AuthConfig | fl
Get-ExchangeCertificate -Thumbprint (Get-AuthConfig).CurrentCertificateThumbprint | fl
Foreach ($i in (Get-ExchangeServer)) {Write-Host $i.FQDN; Get-ExchangeCertificate -Server $i.Identity}
Foreach ($c in (Get-ExchangeCertificate)) {Write-Host $c.Thumbprint; Get-ExchangeCertificate -Thumbprint $c.Thumbprint | fl}   
Get-WebServicesVirtualDirectory -ADPropertiesOnly | fl
Get-AutoDiscoverVirtualDirectory -ADPropertiesOnly | fl
Get-IntraOrganizationConfiguration | fl
Get-IntraOrganizationConnector | fl
Get-AvailabilityAddressSpace | fl
Test-OAuthConnectivity -Service EWS -TargetUri https://outlook.office365.com/ews/exchange.asmx -Mailbox $OnpremMailbox -Verbose | fl
Test-OAuthConnectivity -Service AutoD  -TargetUri https://autodiscover-s.outlook.com/autodiscover/autodiscover.svc -Mailbox $OnpremMailbox -Verbose | fl
Get-Mailbox $OnpremMailbox | fl
Get-RemoteMailbox $CloudMailbox | fl
Get-OrganizationRelationship | fl
Get-OrganizationConfig | fl
Get-CasMailbox $OnpremMailbox | fl
Get-ExchangeServer $ExchangeServer | fl

Get-HybridConfiguration | fl 
Get-FederatedOrganizationIdentifier | fl
Get-FederationTrust | fl
Get-SendConnector | fl
Get-ReceiveConnector | fl
Stop-Transcript


Exchange Online Powershell:
--------------------------

$CloudMailbox = "migrated@CloudUser.com" # REMOTE-Mailbox / migrated (synced with onprem) - Thank You !
$EwsEndpointURI = "https://mail.domain.com/ews/exchange.asmx" # Onprem EWS
$AutoddiscoverURI = "https://mail.domain.com/autodiscover/autodiscover.svc" # Onprem Autodiscover

$VerbosePreference = 'Continue'
$ys = Get-Date -Format yyyyMMdd_hhmmss
$FormatEnumerationLimit = -1
Start-Transcript EXOnline$ys.txt -verbose

Get-IntraOrganizationConfiguration | fl
Get-IntraOrganizationConnector | fl
Get-AuthServer –Identity 00000001-0000-0000-c000-000000000000 | fl
Get-PartnerApplication | fl
Test-OAuthConnectivity -Service EWS -TargetUri $EwsEndpointURI -Mailbox $CloudMailbox -Verbose | fl
Test-OAuthConnectivity -Service AutoD -TargetUri $AutoddiscoverURI -Mailbox $CloudMailbox -Verbose | fl
Get-Mailbox $CloudMailbox | fl
Get-MailUser $OnpremMailbox | fl
Get-OrganizationRelationship | fl
Get-FederatedOrganizationIdentifier | fl
Get-AvailabilityAddressSpace | fl
Get-OnPremisesOrganization | fl
Get-FederationTrust | fl
Get-OutboundConnector | fl
Get-InboundConnector | fl

Stop-Transcript