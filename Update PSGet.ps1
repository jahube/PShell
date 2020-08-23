#Trust Powershell Gallery
if (!(get-PackageProvider nuget)) { write-host "Adding NUGet Package Provider" -F green; Install-PackageProvider -Name NuGet -Force -Scope CurrentUser -Confirm:$false }
if ($((Get-PSRepository -Name "PSGallery").InstallationPolicy) -ne 'trusted') { write-host "Adding PSGallery Trust" -F green;Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted }

Get-Module PowershellGet -ListAvailable

install-module -name PowershellGet -Allowprerelease -Force -Repository PSTestGallery -SkipPublisherCheck

Get-Module PowershellGet -ListAvailable

#modify the max to OLDER value above
Uninstall-Module PowershellGet -MaximumVersion "1.0.0.1" -Force -Confirm:$false -EA stop

#Uninstall-Module PowershellGet -MaximumVersion "2.2.4.1" -Force -Confirm:$false -EA stop

Get-Module PowershellGet -ListAvailable

