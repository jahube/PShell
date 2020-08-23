[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name NuGet -Force -Scope CurrentUser
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

# Check PowershellGet Version (old version 1.0.0.1 reason why Install-Module will not work in Powershell 4
Get-Module PowershellGet -ListAvailable
Install-Module PowershellGet -Force #-Repository PSGallery

#check installed PowershellGet Versions
$Version = Get-InstalledModule PowershellGet ; $Version.Version

#uninstall older PowershellGet 1.0.0.1 (like Powershell 4 on Exchange server) IF new 2.2.4.1 is found from above install
if ($Version.Version -eq "2.2.4.1" ) { 
try { Uninstall-Module PowerShellGet -MaximumVersion 1.0.0.1 -Force -EA stop 
} catch { Write-host "Error: $($Error[0].Exception.Message)" -F yellow }
try { rmdir "$env:ProgramFiles\WindowsPowerShell\Modules\PowerShellGet\1.0.0.1\" -EA stop 
} catch { Write-host "Error: $($Error[0].Exception.Message)" -F yellow }}

#double-check installed PowershellGet Versions
Get-InstalledModule PowershellGet
