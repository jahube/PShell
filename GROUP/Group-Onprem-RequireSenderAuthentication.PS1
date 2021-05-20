#################################################################################################################
# Exchange Onprem Management Shell
#################################################################################################################

$Groups = get-distributiongroup | select Displayname,Identity,PrimarySMTPaddress,SamAccountName,RequireSenderAuthenticationEnabled,Distinguishedname

$Select = $Groups | Out-Gridview -Passthru -Title "Select Groups To Hide"

foreach ($G in $Select) { Set-DistributionGroup $G.distinguishedname -RequireSenderAuthenticationEnabled:$false -Confirm:$false }

#################################################################################################################
# oneliner Exchange Onprem Management Shell
#################################################################################################################

get-distributiongroup | select Dis*me | OGV -P -T "Select Group to Hide" | % { Set-DistributionGroup $_.distinguishedname -RequireSenderAuthenticationEnabled:$false -CF:$false }

#################################################################################################################
# Active Directory / DC
#################################################################################################################

Import-module activedirectory

Set-ADServerSettings -ViewEntireForest $true

$ADGroups = Get-ADGroup -Filter 'groupcategory -eq "Distribution"' -Properties displayName,groupType,objectClass,msExchRequireAuthToSendTo

# -Server localhost:60000 -Filter "GroupScope -eq 'DomainLocal'" -SearchBase "DC=AppNC"

$Filtered = $ADGroups | select Displayname,Identity,PrimarySMTPaddress,SamAccountName,msExchRequireAuthToSendTo,Distinguishedname

$Selected = $Filtered | Out-Gridview -Passthru -Title "Select Groups To Hide"

foreach ($G in $Selected) { Set-ADObject $G.distinguishedname -replace @{msExchRequireAuthToSendTo=$false } }

#################################################################################################################
#  Oneliner versions AD
#################################################################################################################

Get-ADGroup -Filter 'groupcategory -eq "Distribution"' | select Dis*me | OGV -P -T "Select Group to Hide" | % { Set-ADObject $_.distinguishedname -replace @{msExchRequireAuthToSendTo=$false} }

Get-ADGroup -Filter 'groupcategory -eq "Distribution"'|select Dis*me|OGV -P|%{Set-ADObject $_.distinguishedname -replace @{msExchRequireAuthToSendTo=$false} }

Get-ADGroup -Filter 'groupcategory -eq "Distribution"'|OGV -P|%{Set-ADObject $_.distinguishedname -replace @{msExchRequireAuthToSendTo=$false}}