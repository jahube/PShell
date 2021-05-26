standard

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
ICM $([scriptblock]::Create((wget "https://raw.githubusercontent.com/jahube/Logs/main/Migration-Stats.PS1").Content))

webview https://raw.githubusercontent.com/jahube/Logs/main/Migration-Stats.PS1
=========================================================================================================================
long

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
ICM $([scriptblock]::Create((wget "https://raw.githubusercontent.com/jahube/Logs/main/Migration-Stats-long.PS1").Content))

webview https://raw.githubusercontent.com/jahube/Logs/main/Migration-Stats-long.PS1
=========================================================================================================================
after migration

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
ICM $([scriptblock]::Create((wget "https://raw.githubusercontent.com/jahube/Logs/main/migration-stats-after.ps1").Content))

webview https://raw.githubusercontent.com/jahube/Logs/main/migration-stats-after.ps1
=========================================================================================================================

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
wget "https://raw.githubusercontent.com/bergeronK/PowerShell/master/AnalyzeMoveRequestStats.ps1" -OutFile c:\AnalyzeMoveRequestStats.psm1
Import-Module c:\AnalyzeMoveRequestStats.psm1

# Open File Dialog
       $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
   InitialDirectory = [Environment]::GetFolderPath('Desktop')
             Filter = 'XML Files (*.xml)|*.xml' }
              $null = $FileBrowser.ShowDialog()
              $Data = Import-Clixml $FileBrowser.FileName

ProcessStats -stats $Data -name ProcessedStats1