Run from All locations

(1)      Cloud     (3)

Contoso          Fabrikam

(2)      Onprem    (4)

>>> CLOUD

Get-FederationInformation -DomainName Contoso.onmicrosoft.com | New-OrganizationRelationship -Name "Contoso" -FreeBusyAccessEnabled $true -FreeBusyAccessLevel LimitedDetails

>>> ONPREM

Get-FederationInformation -DomainName Contoso.com | New-OrganizationRelationship -Name "Contoso" -FreeBusyAccessEnabled $true -FreeBusyAccessLevel LimitedDetails


# >>> CLOUD
             $domains = 'fabrikam.mail.onmicrosoft.com','fabrikam.onmicrosoft.com'
$ParamCloud = @{ Name = 'Fabrikam Cloud'
          DomainNames = $Clouddomains
TargetAutodiscoverEpr = 'https://outlook.office365.com/autodiscover/autodiscover.svc'
FreeBusyAccessEnabled = $true
  FreeBusyAccessLevel = 'LimitedDetails'
  FreeBusyAccessScope = $null
 TargetApplicationUri = 'outlook.com'
              Enabled = $true }
New-OrganizationRelationship @ParamCloud

# >>> ONPREM
             $domains = 'fabrikam.com','other.fabrikam.com'
$ParamLocal = @{ Name = 'Fabrikam Onprem'
          DomainNames = $domains
TargetAutodiscoverEpr = 'https://mail.fabrikam.com/autodiscover/autodiscover.svc'
FreeBusyAccessEnabled = $true
  FreeBusyAccessLevel = 'LimitedDetails'
  FreeBusyAccessScope = $null
 TargetApplicationUri = 'mail.fabrikam.com'
              Enabled = $true }

New-OrganizationRelationship $ParamLocal