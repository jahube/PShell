# Run All in Exchange management shell 
#  >> set-executionpolicy bypass << if you run frome .\script.ps1 file

$OnpremMailbox = "synced@OnPremUser.com" # <-- Modify

$CloudMailbox = "migrated@CloudUser.com" # <-- Modify

# desktop/MS-Logs+Timestamp
$ts = Get-Date -Format yyyyMMdd_hhmmss
$DesktopPath = ([Environment]::GetFolderPath('Desktop'))
$logsPATH =mkdir "$DesktopPath\MS-Logs\ON-Premise_LOGS_$ts"

Start-Transcript "$logsPATH\ON-Premise_LOGS_$ts.txt"
$FormatEnumerationLimit = -1

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

$MBX = Get-Mailbox $OnpremMailbox -EA silentlycontinue ; IF ((!($MBX)) -or ($_.MailboxMoveRemoteHostName -notlike "*.onmicrosoft.com")) { 
Write-host "$CloudMailbox invalid" -F yellow ; $MBX = (Get-Mailbox | Where-Object {$_.MailboxMoveRemoteHostName -like "*.onmicrosoft.com"})[-1] } 
$OnpremMailbox = $($MBX.primarysmtpaddress) ; IF (!($OnpremMailbox)) { $OnpremMailbox = $((Get-Mailbox)[-1].primarysmtpaddress)}

write-host "Test-OAuthConnectivity"
Test-OAuthConnectivity -Service EWS -TargetUri https://outlook.office365.com/ews/exchange.asmx -Mailbox $OnpremMailbox -Verbose | fl
Test-OAuthConnectivity -Service AutoD  -TargetUri https://autodiscover-s.outlook.com/autodiscover/autodiscover.svc -Mailbox $OnpremMailbox -Verbose | fl

$MBX | fl
Get-RemoteMailbox $CloudMailbox | fl
Get-OrganizationRelationship | fl
Get-OrganizationConfig | fl
Get-CasMailbox $OnpremMailbox | fl
Get-ExchangeServer | fl
Get-HybridConfiguration | fl 
Get-FederatedOrganizationIdentifier | fl
Get-FederationTrust | fl
Get-SendConnector | fl
Get-ReceiveConnector | fl
Get-Remotedomain | fl

# EWS Endpoint for cloud logs
$EWS = (get-webservicesvirtualdirectory).ExternalURL
Write-Host "EWS ENDPOINT`n`n please copy >>  " -F yellow -NoNewline ; Write-host $EWS -F cyan

# Autodiscover
$Auto = (Get-ClientAccessService).AutoDiscoverServiceInternalUri -replace "xml","svc"
Write-Host "`n`nAutodiscover Endpoint`n`n please copy >>  " -F yellow -NoNewline ; Write-host $Auto -F cyan
Stop-Transcript
###### END TRANSCRIPT ######################
$destination = "$DesktopPath\MS-Logs\ON-Premise_LOGS_$ts.zip"
Add-Type -assembly “system.io.compression.filesystem”
[io.compression.zipfile]::CreateFromDirectory($logsPATH, $destination) # ZIP
Invoke-Item $DesktopPath\MS-Logs # open file manager
###### END ZIP Logs ########################