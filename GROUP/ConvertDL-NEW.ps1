# $DL = Get-DistributionGroup –Identity "Test DL2"
# $DL = Get-DistributionGroup -Filter { primarysmtpaddress -like "*Test*"}

# slow
$Menu = Get-DistributionGroup | select DisplayName,Name,@{n= "Members";e={((Get-DistributionGroupMember $_.distinguishedname).count)}},alias,PrimarySmtpAddress,DistinguishedName,GUID
$DL = $Menu | Out-Gridview -Outputmode Single -T "Select Distributionlist to Upgrade"

# fast
# $DL = Get-DistributionGroup | select Disp*e,alias,pri*,Name,GUID,distinguishedname | Out-Gridview -Outputmode Single -T "Select Distributionlist to Upgrade"

$Path = [Environment]::GetFolderPath('MyDocuments')

$DL | Export-Csv -Path "$Path\DL_$($DL.Name).csv" -NoTypeInformation -Encoding UTF8 -Force ; $DL

$Members = Get-DistributionGroupMember –Identity $DL.distinguishedname –ResultSize Unlimited
$Members | Export-Csv -Path "$Path\exportDL_$($DL.Name).csv" -NoTypeInformation -Encoding UTF8
$Members | select *name*,alias,pri*,GUID | Export-Csv -Path "$Path\exportDLshort.csv" -NoTypeInformation -Encoding UTF8 -Force

Remove-DistributionGroup -identity $DL.DistinguishedName

sleep 5

New-UnifiedGroup -name $DL.Name -Alias $DL.Alias -PrimarySmtpAddress $DL.PrimarySmtpAddress -DisplayName $DL.DisplayName
Set-UnifiedGroup -Identity $DL.Name -DisplayName $DL.DisplayName -Alias $DL.Alias -RequireSenderAuthenticationEnabled $false -SubscriptionEnabled -AutoSubscribeNewMembers

for ($M = 0; $M -lt $Members.count;) {
try { Add-UnifiedGroupLinks -Identity $DL.Name -LinkType member -Links ($Members[$M]).DistinguishedName -EA stop -CF:$false } catch { $error[0] | FL * -F ;
Add-UnifiedGroupLinks -Identity $DL.Name -LinkType member -Links ($Members[$M]).DistinguishedName -CF:$false } ;$M++ ;
Write-Progress -Activity "Adding Member" -Id 2 -ParentId 1 -Status "Member: $(($Members[$M]).DisplayName)" -PercentComplete (($M/$Members.count)*100) }

#########################################################################################
############## Restart From CSV Only ####################################################

$RestoreMode = $true

IF ($RestoreMode) {

      # DL Filedialog
       $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
   InitialDirectory = [Environment]::GetFolderPath('MyDocuments')
             Filter = 'CSV Files (*.CSV)|*.CSV' }
              $null = $FileBrowser.ShowDialog()
                $DL = Import-Csv $FileBrowser.FileName

#create new O365 Group with same Properties
New-UnifiedGroup -name $DL.Name -Alias $DL.Alias -PrimarySmtpAddress $DL.PrimarySmtpAddress -DisplayName $DL.DisplayName
Set-UnifiedGroup -Identity $DL.Name -DisplayName $DL.DisplayName -Alias $DL.Alias -RequireSenderAuthenticationEnabled $false -SubscriptionEnabled -AutoSubscribeNewMembers

                   # Members Filedialog
              $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
          InitialDirectory = [Environment]::GetFolderPath('MyDocuments')
                    Filter = 'CSV Files (*.CSV)|*.CSV' }
                     $null = $FileBrowser.ShowDialog()
                  $Members = Import-Csv $FileBrowser.FileName
#ADD Members
for ($M = 0; $M -lt $Members.count;) {
try { Add-UnifiedGroupLinks -Identity $DL.Name -LinkType member -Links ($Members[$M]).DistinguishedName -EA stop -CF:$false } catch { $error[0] | FL * -F ;
Add-UnifiedGroupLinks -Identity $DL.Name -LinkType member -Links ($Members[$M]).DistinguishedName -EA stop -CF:$false } ;$M++ ;
Write-Progress -Activity "Adding Member" -Id 2 -ParentId 1 -Status "Member: $($Members[$M].DisplayName)" -PercentComplete (($M/$Members.count)*100) }
} # end
############## End / Restore ####################################################

#result
get-UnifiedGroup -Identity $DL.Name
(get-UnifiedGroupLinks -Identity $DL.Name -LinkType member).count
# Finished
-------------------------------------------------------------
#############################################################
Below is just for reference to remove from exportDLremove.csv
#############################################################
REMOVE - ONLY FOR REFERENCE

$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
   InitialDirectory = [Environment]::GetFolderPath('MyDocuments')
             Filter = 'CSV Files (*.CSV)|*.CSV' }
              $null = $FileBrowser.ShowDialog()
           $Members = Import-Csv $FileBrowser.FileName }

#$Path = "C:\temp"
#$Members = Import-Csv -Path "$Path\exportDL_$($DL.Name).csv" -Encoding UTF8

for ($M = 0; $M -lt $Members.count;) {
try { remove-UnifiedGroupLinks -Identity $DL.Name -LinkType member -Links "$(($Members[$M]).DistinguishedName)" -Confirm:$false } catch { $error[0] | FL * -F }
$M++ ; Write-Progress -Activity "Removing Members" -Id 2 -ParentId 1 -Status "Member: $(($Members[$M]).DisplayName)" -PercentComplete (($M/$Members.count)*100) }

#result
get-UnifiedGroup -Identity $DL.Name
(get-UnifiedGroupLinks -Identity $DL.Name -LinkType member).count