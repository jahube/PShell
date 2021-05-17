#Modify the name please
$DL = Get-DistributionGroup –Identity "Test DL2"
$DL = Get-DistributionGroup -Filter { primarysmtpaddress -like "*Test*"}

$Path "C:\Temp"

#check
$DL
$Members = Get-DistributionGroupMember –Identity $DL.distinguishedname –ResultSize Unlimited
$Members | Export-Csv -Path "$Path\exportDL.csv" -NoTypeInformation -Encoding UTF8
$Members | select *name*,alias,pri*,GUID | Export-Csv -Path "$Path\exportDLshort.csv" -NoTypeInformation -Encoding UTF8
# $Members = Import-Csv -Path "$Path\exportDL.csv" -Encoding UTF8

#delete DL after export
Remove-DistributionGroup -identity $DL.DistinguishedName

#create new O365 Group with same Properties
New-UnifiedGroup -name $DL.Name -Alias $DL.Alias -PrimarySmtpAddress $DL.PrimarySmtpAddress -DisplayName $DL.DisplayName
Set-UnifiedGroup -Identity $DL.Name -DisplayName $DL.DisplayName -Alias $DL.Alias -RequireSenderAuthenticationEnabled $false -SubscriptionEnabled -AutoSubscribeNewMembers
#ADD Members
$mcount = 1
$Memberscount = $Members.count
Foreach ($Member in $Members) { 
Write-Progress -Activity "Adding Member" -Id 2 -ParentId 1 -Status "Member: $($Member.DisplayName)" -PercentComplete (($mcount/$Memberscount)*100)
try { Add-UnifiedGroupLinks -Identity $DL.Name -LinkType member -Links $Member.GUID -Confirm:$false } catch { Writehost $error[0] }
$mcount++
}

#result
get-UnifiedGroup -Identity $DL.Name
(get-UnifiedGroupLinks -Identity $DL.Name -LinkType member).count
# Finished
-------------------------------------------------------------
#############################################################
Below is just for reference to remove from exportDLremove.csv
#############################################################
REMOVE - ONLY FOR REFERENCE
$Path = "C:\temp"
$Members = Import-Csv -Path "$Path\exportDLremove.csv" -Encoding UTF8
$rcount = 1
Foreach ($Member in $Members) { 
Write-Progress -Activity "Removing Members" -Id 2 -ParentId 1 -Status "Member: $($Member.DisplayName)" -PercentComplete (($rcount/$Memberscount)*100)
try { remove-UnifiedGroupLinks -Identity $DL.Name -LinkType member -Links $Member.GUID -Confirm:$false } catch { Writehost $error[0] }
$rcount++
}

#result
get-UnifiedGroup -Identity $DL.Name
(get-UnifiedGroupLinks -Identity $DL.Name -LinkType member).count 

