# REMOTE-Mailbox / migrated (synced with onprem) - Thank You !
$CloudMailbox = "Any@Remote-Mailbox.com"  # <-- Modify

# Auto - select + run to verify
$MigrationEndpoint = (Get-MigrationEndpoint | ? {$_.identity -match "Hybrid"}).remoteserver ; $EwsEndpointURI = 'https://' + $MigrationEndpoint +  '/ews/exchange.asmx'; $EwsEndpointURI # Onprem EWS
$AutoddiscoverURI = $((Get-IntraOrganizationConnector)[-1].DiscoveryEndpoint.AbsoluteUri) ; $AutoddiscoverURI

# Manual Alternative: copy from ONPREM Outputs and remove '#'
# $EwsEndpointURI = "https://mail.domain.com/ews/exchange.asmx" # Onprem EWS
# $AutoddiscoverURI = "https://mail.domain.com/autodiscover/autodiscover.svc" # Onprem Autodiscover

# desktop/MS-Logs+Timestamp
$ts = Get-Date -Format yyyyMMdd_hhmmss
$DesktopPath = ([Environment]::GetFolderPath('Desktop'))
$logsPATH = mkdir "$DesktopPath\MS-Logs\EXO_LOGS_$ts"

Start-Transcript "$logsPATH\EXO_LOGS_$ts.txt"
$FormatEnumerationLimit = -1

Get-IntraOrganizationConfiguration | fl
Get-IntraOrganizationConnector | fl
Get-AuthServer –Identity 00000001-0000-0000-c000-000000000000 | fl
Get-PartnerApplication | fl

$MBX = Get-Mailbox $CloudMailbox -EA silentlycontinue ; 
IF ((!($MBX)) -or ($MBX.isdirsynced -ne 'true')) { Write-host "$CloudMailbox invalid" -F yellow ; $MBX = (Get-Mailbox | where {$_.isdirsynced -eq 'true' })[-1] } #fallback if $CloudMailbox is invalid ; 
$CloudMailbox = $($MBX.primarysmtpaddress) 
$MBX | fl ; (Get-MailUser)[-1] | fl

write-host "Test-OAuthConnectivity"
Test-OAuthConnectivity -Service EWS -TargetUri $EwsEndpointURI -Mailbox $CloudMailbox -Verbose | fl
Test-OAuthConnectivity -Service AutoD -TargetUri $AutoddiscoverURI -Mailbox $CloudMailbox -Verbose | fl

Get-OrganizationRelationship | fl
Get-FederatedOrganizationIdentifier | fl
Get-AvailabilityAddressSpace | fl
Get-OnPremisesOrganization | fl
Get-FederationTrust | fl
Get-OutboundConnector | fl
Get-InboundConnector | fl

Stop-Transcript

Compress-Archive -Path $logsPATH -DestinationPath "$DesktopPath\MS-Logs\EXO_LOGS_$ts.zip" -Force # Zip Logs
Invoke-Item $DesktopPath\MS-Logs # open file manager