# Exchange Onprem Management Shell

$Groups = get-distributionlist | select Displayname,Identity,PrimarySMTPaddress,SamAccountName,Distinguishedname

$Select = $Groups | Outgridview -Passthru -Title "Select Groups To Hide"

$foreach ($G in $Select) { Set-DistributionGroup -HiddenFromAddressListsEnabled $true -Confirm:$false }


# Active Directory / DC

Import-module activedirectory

ADSet-ADServerSettings -ViewEntireForest $true

$ADGroups = Get-ADGroup $group -Properties displayName,groupType,objectClass 

$Filtered = $ADGroups | select Displayname,Identity,PrimarySMTPaddress,SamAccountName,Distinguishedname

$Selected = $Filtered | Outgridview -Passthru -Title "Select Groups To Hide"
 
$foreach ($G in $Selected)Set-ADObject $Group.distinguishedname -replace @{msExchHideFromAddressLists=$true}