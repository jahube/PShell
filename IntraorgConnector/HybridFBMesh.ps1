Run from All locations

(1)      Cloud     (3)

Contoso          Fabrikam

(2)      Onprem    (4)


>>> CLOUD
Get-FederationInformation -DomainName Contoso.onmicrosoft.com | New-OrganizationRelationship -Name "Contoso" -FreeBusyAccessEnabled $true -FreeBusyAccessLevel LimitedDetails

>>> ONPREM
Get-FederationInformation -DomainName Contoso.com | New-OrganizationRelationship -Name "Contoso" -FreeBusyAccessEnabled $true -FreeBusyAccessLevel LimitedDetails


<Manually>

>>> CLOUD
              $access = ‘LimitedDetails’
           $CloudName = "Fabrikam Cloud"
        $Clouddomains = "fabrikam.mail.onmicrosoft.com","fabrikam.onmicrosoft.com"
       $clouddiscover = "https://outlook.office365.com/autodiscover/autodiscover.svc" 
   $TargetAppURICloud = "outlook.com"

$PARAM = @{      Name = $CloudName
          DomainNames = $Clouddomains
TargetAutodiscoverEpr = $clouddiscover
FreeBusyAccessEnabled = $true
  FreeBusyAccessLevel = $access
  FreeBusyAccessScope = $null
 TargetApplicationUri = $TargetAppURICloud
              Enabled = $true }


>>> ONPREM

Get-FederationInformation -DomainName Contoso.com | New-OrganizationRelationship -Name "Contoso" -FreeBusyAccessEnabled $true -FreeBusyAccessLevel LimitedDetails

OR 

              $access = ‘LimitedDetails’
           $LocalName = "Fabrikam Onprem"
        $Localdomains = "fabrikam.com","other.fabrikam.com"
   $LocalAutodiscover = "https://mail.fabrikam.com/autodiscover/autodiscover.svc"
   $TargetAppURIlocal = "mail.fabrikam.com"

$PARAM = @{      Name = $LocalName
          DomainNames = $Localdomains
TargetAutodiscoverEpr = $LocalAutodiscover
FreeBusyAccessEnabled = $true
  FreeBusyAccessLevel = $access
  FreeBusyAccessScope = $null
 TargetApplicationUri = $TargetAppURIlocal
              Enabled = $true }