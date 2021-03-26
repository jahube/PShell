#################################################################################################################
# Exchange Onprem Management Shell
#################################################################################################################

$Groups = get-distributionlist | select Displayname,Identity,PrimarySMTPaddress,SamAccountName,Distinguishedname

$Select = $Groups | Out-Gridview -Passthru -Title "Select Groups To Hide"

$foreach ($G in $Select) { Set-DistributionGroup -ReportToOriginatorEnabled:$true -Confirm:$false }

#################################################################################################################
# oneliner Exchange Onprem Management Shell
#################################################################################################################

get-distributionlist | select Dis*me | OGV -P -T "Select Group to Hide" | Set-DistributionGroup -ReportToOriginatorEnabled:$true -CF:$false

#################################################################################################################
# Active Directory / DC
#################################################################################################################

Import-module activedirectory

ADSet-ADServerSettings -ViewEntireForest $true

$ADGroups = Get-ADGroup -Filter 'groupcategory -eq "Distribution"' -Properties displayName,groupType,objectClass

# -Server localhost:60000 -Filter "GroupScope -eq 'DomainLocal'" -SearchBase "DC=AppNC"

$Filtered = $ADGroups | select Displayname,Identity,PrimarySMTPaddress,SamAccountName,Distinguishedname

$Selected = $Filtered | Out-Gridview -Passthru -Title "Select Groups To Hide"
 
$foreach ($G in $Selected) { Set-ADObject $Group.distinguishedname -replace @{reportToOriginator=$true} }

#################################################################################################################
#  Oneliner versions AD
#################################################################################################################

Get-ADGroup -Filter 'groupcategory -eq "Distribution"' | select Dis*me | OGV -P -T "Select Group to Hide" | % { Set-ADObject $_.distinguishedname -replace @{reportToOriginator=$true} }

Get-ADGroup -Filter 'groupcategory -eq "Distribution"'|select Dis*me|OGV -P|%{Set-ADObject $_.distinguishedname -replace @{reportToOriginator=$true} }

Get-ADGroup -Filter 'groupcategory -eq "Distribution"'|OGV -P|%{Set-ADObject $_.distinguishedname -replace @{reportToOriginator=$true}}
