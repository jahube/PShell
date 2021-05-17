
# $DL = Get-DistributionGroup –Identity "Test DL2"
# $DL = Get-DistributionGroup -Filter { primarysmtpaddress -like "*Test*"}

# "Menu" - pick DL to upgrade
$DL = Get-DistributionGroup | select *name*,alias,pri*,GUID | Out-Gridview -Outputmode Single -T "Select Distributionlist to Upgrade"

# documents   #OR $Path "C:\Temp"
$Path = ([Environment]::GetFolderPath('MyDocuments'))

#DL export
$DL | Export-Csv -Path "$Path\DL_$($DL.Name).csv" -NoTypeInformation -Encoding UTF8 -Force

#check
$DL # $DL = Import-Csv -Path "$Path\DL_$($DL.Name).csv" -Encoding UTF8

#MEMBERS export
$Members = Get-DistributionGroupMember –Identity $DL.distinguishedname –ResultSize Unlimited
$Members | Export-Csv -Path "$Path\exportDL_$($DL.Name).csv" -NoTypeInformation -Encoding UTF8
$Members | select *name*,alias,pri*,GUID | Export-Csv -Path "$Path\exportDLshort.csv" -NoTypeInformation -Encoding UTF8 -Force
# $Members = Import-Csv -Path "$Path\exportDL_$($DL.Name).csv" -Encoding UTF8

#delete DL after export
Remove-DistributionGroup -identity $DL.DistinguishedName

sleep 5

#create new O365 Group with same Properties
New-UnifiedGroup -name $DL.Name -Alias $DL.Alias -PrimarySmtpAddress $DL.PrimarySmtpAddress -DisplayName $DL.DisplayName
Set-UnifiedGroup -Identity $DL.Name -DisplayName $DL.DisplayName -Alias $DL.Alias -RequireSenderAuthenticationEnabled $false -SubscriptionEnabled -AutoSubscribeNewMembers

#ADD Members
for ($M = 0; $M -lt $Members.count;) {
  try { Add-UnifiedGroupLinks -Identity $DL.Name -LinkType member -Links $Members[$M].DistinguishedName -EA stop -CF:$false }
catch { Add-UnifiedGroupLinks -Identity $DL.Name -LinkType member -Links $Members[$M].userprincipalname -CF:$false } ;
$M++ ; Write-Progress -Activity "Adding Member" -Id 2 -ParentId 1 -Status $Members[$M].DisplayName -PercentComplete (($M/$Members.count)*100) } # end


#result
get-UnifiedGroup -Identity $DL.Name
(get-UnifiedGroupLinks -Identity $DL.Name -LinkType member).count
# Finished

