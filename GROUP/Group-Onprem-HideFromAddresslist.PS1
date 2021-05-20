#################################################################################################################
# Exchange Onprem Management Shell
#################################################################################################################

$Groups = get-distributiongroup | select Displayname,Identity,PrimarySMTPaddress,SamAccountName,HiddenFromAddressListsEnabled,Distinguishedname

$Select = $Groups | Out-Gridview -Passthru -Title "Select Groups To Hide"

foreach ($G in $Select) { Set-distributiongroup $G.distinguishedname -HiddenFromAddressListsEnabled $true -Confirm:$false }

#################################################################################################################
# oneliner Exchange Onprem Management Shell
#################################################################################################################

get-distributiongroup | select Dis*me | OGV -P -T "Select Group to Hide" | % { Set-DistributionGroup $_.distinguishedname -HiddenFromAddressListsEnabled:$true -CF:$false }

#################################################################################################################
# Active Directory / DC
#################################################################################################################

Import-module activedirectory

Set-ADServerSettings -ViewEntireForest $true

$ADGroups = Get-ADGroup -Filter 'groupcategory -eq "Distribution"' -Properties displayName,groupType,objectClass,msExchHideFromAddressLists

# -Server localhost:60000 -Filter "GroupScope -eq 'DomainLocal'" -SearchBase "DC=AppNC"

$Filtered = $ADGroups | select Displayname,Identity,PrimarySMTPaddress,SamAccountName,msExchHideFromAddressLists,Distinguishedname

$Selected = $Filtered | Out-Gridview -Passthru -Title "Select Groups To Hide"
 
foreach ($G in $Selected) { Set-ADObject $G.distinguishedname -replace @{msExchHideFromAddressLists=$true} }

#################################################################################################################
#  Oneliner versions AD
#################################################################################################################

Get-ADGroup -Filter 'groupcategory -eq "Distribution"' | select Dis*me | OGV -P -T "Select Group to Hide" | % { Set-ADObject $_.distinguishedname -replace @{msExchHideFromAddressLists=$true} }

Get-ADGroup -Filter 'groupcategory -eq "Distribution"'|select Dis*me|OGV -P|%{Set-ADObject $_.distinguishedname -replace @{msExchHideFromAddressLists=$true} }

Get-ADGroup -Filter 'groupcategory -eq "Distribution"' | OGV -P | % { Set-ADObject $_.distinguishedname -replace @{msExchHideFromAddressLists=$true} }

Get-ADGroup | OGV -P | % { Set-ADObject $_.distinguishedname -replace @{msExchHideFromAddressLists=$true} }