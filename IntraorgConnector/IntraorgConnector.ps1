$access = ‘LimitedDetails’

$IOCNAME = "FreeBusy Fabrikam" # MODIFY

$ServiceDomain = "otherTENANT.mail.onmicrosoft.com" # MODIFY
# $ServiceDomain = (Get-AcceptedDomain | ? {$_.DomainName -match ".mail.onmicrosoft.com"}).Name

$Federation = icm { Get-FederationInformation -DomainName $ServiceDomain } # pulls othter tenants federation info

#For cloud AS IS / for onprem modifiy autodiscover to other ORG onprem Autodiscover endpoint
$clouddiscover = "https://outlook.office365.com/autodiscover/autodiscover.svc" 

# NEW ORG RELATIONSHIP
$Federation | New-OrganizationRelationship -Name $IOCNAME -Enabled $true -FreeBusyAccessEnabled $true -FreeBusyAccessLevel $access -FreeBusyAccessScope $null

Get-OrganizationRelationship | ? {$_.domainnames -match $ServiceDomain } | fl

# NEW INTRAORG CONNECTOR
New-IntraOrganizationConnector -name $IOCNAME -DiscoveryEndpoint $clouddiscover -TargetAddressDomains $Federation.domainnames

Get-IntraOrganizationConnector $IOCNAME | fl
Get-IntraOrganizationConfiguration (Get-OrganizationConfig).guid.guid

# Remove - for reference only
# Get-OrganizationRelationship | ? {$_.domainnames -match $ServiceDomain } | Remove-OrganizationRelationship
# Get-IntraOrganizationConnector $IOCNAME | Remove-IntraOrganizationConnector