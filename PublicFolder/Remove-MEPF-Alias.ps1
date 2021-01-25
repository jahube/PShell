
$MEPF = Get-MailPublicFolder
$MEPF | select -ExpandProperty emailaddresses

# VARIABLES

$OldAddress = "OldAddress@tenant.onmicrosoft.com"
$NewAddress = "NewAddress@tenant.onmicrosoft.com"
$NewAlias = "NewAlias"

$NewDisplayname = "New Alias"

# Version 1

   $Param = @{      Alias = $NewAlias
                 Identity = $OldAddress
       PrimarySmtpAddress = $NewAddress
      WindowsEmailAddress = $NewAddress
EmailAddressPolicyEnabled = $false }

Set-MailPublicFolder @Param
Set-MailPublicFolder $NewAlias -EmailAddresses @{Remove=$OldAddress}

# Version 2

Set-MailPublicFolder -Identity $MatchingMEPF.PrimarySmtpAddress -PrimarySmtpAddress $Newaddress -alias $NewAlias -WindowsEmailAddress $NewAddress -EmailAddressPolicyEnabled $false

Set-MailPublicFolder $NewAlias -EmailAddresses @{Remove=$OldAddress}

get-MailPublicFolder -Identity $Newaddress | fl PrimarySmtpAddress, EmailAddresses, DisplayName, WindowsEmailAddress, Alias, EmailAddressPolicyEnabled, EntryId

# SEARCH

$searchstring = "OldAddress"
$NEWalias = "NewAlias"

$MatchingMEPF = $MEPF| where-object { $_.emailaddresses -match $searchstring }
IF ($MatchingMEPF) {Write-host $($MatchingMEPF.Identity) $($MatchingMEPF.EntryID) $($MatchingMEPF.EmailAddresses) -F green }

get-MailPublicFolder -Identity $MatchingMEPF.PrimarySmtpAddress | fl PrimarySmtpAddress, EmailAddresses, DisplayName, WindowsEmailAddress, Alias, EmailAddressPolicyEnabled, EntryId

$Newaddress = $NEWalias + '@' + $($MatchingMEPF.PrimarySmtpAddress -split '@')[1]
$Newaddress 

# SEARCH Dumpster MEPF

$Dumpster = Get-PublicFolder –Identity "\Non_IPM_Subtree\Dumpster_Root" –Recurse
$dumpsterMEPF = $Dumpster | Get-MailPublicFolder -ResultSize unlimited -ErrorAction SilentlyContinue
$dumpsterMatch = $dumpsterMEPF| where-object { $_.emailaddresses -match $searchstring }
IF ($dumpsterMatch) {Write-host $($dumpsterMatch.Identity) $($dumpsterMatch.EntryID) $($dumpsterMatch.EmailAddresses) -F green }

get-MailPublicFolder -Identity $dumpsterMatch.PrimarySmtpAddress | fl PrimarySmtpAddress, EmailAddresses, DisplayName, WindowsEmailAddress, Alias, EmailAddressPolicyEnabled, EntryId

get-MailPublicFolder -Identity $dumpsterMatch.PrimarySmtpAddress | Disable-MailPublicFolder
