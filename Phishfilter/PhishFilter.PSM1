
Param (
[Parameter(Mandatory = $false)]
[String]$InFolder  = ( [String]( $([Environment]::GetFolderPath('Desktop') ) + "\Spoofed_Senders") ),
[String]$OutFolder = ( [String]( $([Environment]::GetFolderPath('Desktop') ) + "\Spoofed_Senders\MOD") ),
[String]$InFile,
[String]$OutFile,
[String]$Days,
[String]$ViewOnly,
[switch]$OpenFileDialog
)
 If(!($InFile) -and (Test-Path -Path $InFolder)) { $InFile = try { (get-childitem $InFolder -ErrorAction stop)[-1].VersionInfo.FileName } catch {} }
 If(!(Test-Path -Path $InFolder)) { mkdir $InFolder }
 If(!(Test-Path -Path $InFolder)) { mkdir $InFolder }
 If(!(Test-Path -Path $OutFolder)) { mkdir $OutFolder}

 IF($InFile) { $Global:InFile = $InFile ;
 $Global:Data = Try { Import-CSV $Global:InFile -ErrorAction Stop } catch {} }
 
Function Open-FileDialog
{
# Open File Dialog
       $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
   InitialDirectory = $Global:InFolder
             Filter = 'CSV Files (*.csv)|*.csv' }
              $null = $FileBrowser.ShowDialog()
     $Global:InFile = $FileBrowser.FileName
       $Global:Data = Import-CSV $FileBrowser.FileName
}

IF ($OpenFileDialog) { Open-FileDialog }

 If(!($Global:Data)) { $Global:Data = Get-PhishFilterPolicy -Detailed ;
 $ts = Get-Date -Format yyyy-MM-dd_hh-mm ;
 $Global:Data | Export-CSV "$logsPATH\Spoofed_Senders_$ts.csv" -NoTypeInformation -Force }


#################################################################################################################################################

 Function PhishView
 { if(!($Days)) { $Days = "14" }

  If(!($Global:Data)) { $Global:Data = Get-PhishFilterPolicy -Detailed ;

 $ts = Get-Date -Format yyyy-MM-dd_hh-mm ;

 $Global:Data | Export-CSV "$OutFolder\Spoofed_Senders_$ts.csv" -NoTypeInformation -Force }

$LastData = $Global:Data | Sort-Object LastSeen -Descending | where { $_.LastSeen -ge (Get-Date).AddDays(-$Days) }

$LastData | Out-GridView -Title "View Only"
}

IF ($ViewOnly) { PhishView }

#################################################################################################################################################

 Function compareData
{

# Open File Dialog
       $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
   InitialDirectory = [Environment]::GetFolderPath('Desktop')
             Filter = 'CSV Files (*.csv)|*.csv' }
              $null = $FileBrowser.ShowDialog()
       $ImportData = Import-CSV $FileBrowser.FileName

# $compareData = $ImportData.emailadresse

$compareData = $ImportData

$CompareDomains = @()
foreach ($D in $compareData) {
IF ($D -match '@' ) { $CompareDomains += ($D -split "@")[1] }
            ELSE { $CompareDomains += $D } }

$Global:FilterData = $Global:Data | where { $_.spoofeduser -in $CompareDomains -or $_.sender -in $CompareDomains -or @($_.spoofeduser -split '@')[1] -in $CompareDomains -or ($_.sender -split '@')[1] -in $CompareDomains }

}

#################################################################################################################################################

Function Remove-AllowPhish
{

If(!($Global:Data)) { $Global:Data = Get-PhishFilterPolicy -Detailed }

$Remove_List = $Global:Data | where { $_.AllowedToSpoof -eq "Yes" } | Out-GridView -Title "Select Allowed Senders To REMOVE from Allow List" -PassThru

for ($R = 0; $R -lt $($Remove_List).count; $R++) { $Remove_List[$R].AllowedToSpoof = "No" }

$ts = Get-Date -Format yyyy-MM-dd_hh-mm

$Remove_Path = "$($Global:OutFolder + "\Remove_List_$ts.csv")"

$Remove_List | Export-CSV $Remove_Path -NoTypeInformation -Force

$Remove_File = Get-Content -Raw $Remove_Path

Set-PhishFilterPolicy -Identity Default -SpoofAllowBlockList $Remove_File

}

#################################################################################################################################################

Function Add-AllowPhish
{

If(!($Global:Data)) { $Global:Data = Get-PhishFilterPolicy -Detailed }

$Allow_List = $Global:Data | where { $_.AllowedToSpoof -eq "No" } | Out-GridView -Title "Select blocked Senders to Allow Spoofing in future" -PassThru

for ($A = 0; $A -lt $($Allow_List).count; $A++) { $Allow_List[$A].AllowedToSpoof = "Yes" }

$ts = Get-Date -Format yyyy-MM-dd_hh-mm

$Allow_Path = "$($Global:OutFolder + "\Allow_List_$ts.csv")"

$Allow_List | Export-CSV $Allow_Path -NoTypeInformation -Force

$Allow_File = Get-Content -Raw $Allow_Path

Set-PhishFilterPolicy -Identity Default -SpoofAllowBlockList $Allow_File
}

####################################################################################
<#
Open-FileDialog

$Global:Data = Get-PhishFilterPolicy -Detailed

Remove-AllowPhish

Add-AllowPhish
#>