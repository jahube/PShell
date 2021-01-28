
$access = ‘LimitedDetails’

$CloudName = "Fabrikam Cloud"

$Clouddomains = "otherTENANT.mail.onmicrosoft.com","otherTENANT.onmicrosoft.com"

$clouddiscover = "https://outlook.office365.com/autodiscover/autodiscover.svc" 

$PARAM = @{      Name = $CloudName
          DomainNames = $Clouddomains
TargetAutodiscoverEpr = $clouddiscover
FreeBusyAccessEnabled = $true 
  FreeBusyAccessLevel = $access 
  FreeBusyAccessScope = $null 
              Enabled = $true }


$access = ‘LimitedDetails’

$LocalName = "Fabrikam Onprem"

$Localdomains = "fabrikam.com","other.fabrikam.com"

$LocalAutodiscover = "https://mail.fabrikam.com/autodiscover/autodiscover.svc"

$PARAM = @{      Name = $LocalName
          DomainNames = $Localdomains
TargetAutodiscoverEpr = $LocalAutodiscover
FreeBusyAccessEnabled = $true 
  FreeBusyAccessLevel = $access 
  FreeBusyAccessScope = $null 
              Enabled = $true }