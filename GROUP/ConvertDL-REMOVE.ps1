#############################################################
Below is just for reference to remove from exportDLremove.csv
#############################################################
REMOVE - ONLY FOR REFERENCE

#$Path = "C:\temp"
#$Members = Import-Csv -Path "$Path\exportDL_$($DL.Name).csv" -Encoding UTF8

      # DL Filedialog
       $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
   InitialDirectory = [Environment]::GetFolderPath('MyDocuments')
             Filter = 'CSV Files (*.CSV)|*.CSV' }
              $null = $FileBrowser.ShowDialog()
                $DL = Import-Csv $FileBrowser.FileName


                   # Members Filedialog
              $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
          InitialDirectory = [Environment]::GetFolderPath('MyDocuments')
                    Filter = 'CSV Files (*.CSV)|*.CSV' }
                     $null = $FileBrowser.ShowDialog()
                  $Members = Import-Csv $FileBrowser.FileName

#result
get-UnifiedGroup -Identity $DL.Name
(get-UnifiedGroupLinks -Identity $DL.Name -LinkType member).count
# Finished

<#

# REMOVE MEMBERS FROM CSV

for ($M = 0; $M -lt $Members.count;) {
try { remove-UnifiedGroupLinks -Identity $DL.Name -LinkType member -Links "$(($Members[$M]).DistinguishedName)" -EA stop -Confirm:$false } catch { $error[0] | FL * -F }
$M++ ; Write-Progress -Activity "Removing Members" -Id 2 -ParentId 1 -Status "Member: $(($Members[$M]).DisplayName)" -PercentComplete (($M/$Members.count)*100) }

#result
get-UnifiedGroup -Identity $DL.Name
(get-UnifiedGroupLinks -Identity $DL.Name -LinkType member).count

#>