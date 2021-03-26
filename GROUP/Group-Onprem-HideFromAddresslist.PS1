#################################################################################################################
# Exchange Onprem Management Shell
#################################################################################################################

$Groups = get-distributiongroup | select Displayname,Identity,PrimarySMTPaddress,SamAccountName,Distinguishedname

$Select = $Groups | Out-Gridview -Passthru -Title "Select Groups To Hide"

$foreach ($G in $Select) { Set-distributiongroup -HiddenFromAddressListsEnabled $true -Confirm:$false }

#################################################################################################################
# oneliner Exchange Onprem Management Shell
#################################################################################################################

get-distributiongroup | select Dis*me | OGV -P -T "Select Group to Hide" | Set-DistributionGroup -HiddenFromAddressListsEnabled:$true -CF:$false

#################################################################################################################
# Active Directory / DC
#################################################################################################################

Import-module activedirectory

ADSet-ADServerSettings -ViewEntireForest $true

$ADGroups = Get-ADGroup -Filter 'groupcategory -eq "Distribution"' -Properties displayName,groupType,objectClass

# -Server localhost:60000 -Filter "GroupScope -eq 'DomainLocal'" -SearchBase "DC=AppNC"

$Filtered = $ADGroups | select Displayname,Identity,PrimarySMTPaddress,SamAccountName,Distinguishedname

$Selected = $Filtered | Out-Gridview -Passthru -Title "Select Groups To Hide"
 
$foreach ($G in $Selected) { Set-ADObject $Group.distinguishedname -replace @{msExchHideFromAddressLists=$true} }

#################################################################################################################
#  Oneliner versions AD
#################################################################################################################

Get-ADGroup -Filter 'groupcategory -eq "Distribution"' | select Dis*me | OGV -P -T "Select Group to Hide" | % { Set-ADObject $_.distinguishedname -replace @{msExchHideFromAddressLists=$true} }

Get-ADGroup -Filter 'groupcategory -eq "Distribution"'|select Dis*me|OGV -P|%{Set-ADObject $_.distinguishedname -replace @{msExchHideFromAddressLists=$true} }

Get-ADGroup -Filter 'groupcategory -eq "Distribution"' | OGV -P | % { Set-ADObject $_.distinguishedname -replace @{msExchHideFromAddressLists=$true} }

Get-ADGroup | OGV -P | % { Set-ADObject $_.distinguishedname -replace @{msExchHideFromAddressLists=$true} }