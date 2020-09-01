
# Check / Update installed Exchange Online Powershell V2 Module Version
$EXO = Get-InstalledModule ExchangeOnlineManagement ;
If ($EXO.Version -lt "2.0.3" ) { 

Write-Host "$($EXO.Version) Version outdated" -F yellow
Get-Module ExchangeOnlineManagement -ListAvailable

Try { Write-Host "Installing latest Version" -F cyan 
install-module -name ExchangeOnlineManagement -Allowprerelease -Force -EA stop #-Repository PSGallery 
     Write-Host "Version 2.0.3 successfully installed" -F green 
     } catch { Write-host "Error: $($Error[0].Exception.Message)" -F yellow }     
} else { Write-Host "$($EXO.Version) already updated" -F green }

# clear old Version 1.0.1 if new Version 2.0.3 is found
$EXOupd = Get-Module ExchangeOnlineManagement -ListAvailable
if ($EXOupd.Version -match "2.0.3" -and $EXOupd.Version -match "1.0.1" ) { 

#try uninstall "1.0.1"
try { Write-Host "Trying Uninstall-Module for Version 1.0.1" -F cyan
If (get-pssession | where { $_.ConfigurationName -match "Microsoft.Exchange"}) { Disconnect-ExchangeOnline -CF:$false }
Uninstall-Module ExchangeOnlineManagement -MaximumVersion "1.0.1" -Force -Confirm:$false -EA stop
Write-Host "OLD duplicated Version 1.0.1 successfully uninstalled" -F green

# only if uninstall "1.0.1" not successful delete module directory or throw error
} catch { Write-host "Error: $($Error[0].Exception.Message)" -F yellow
            try { rmdir "$env:ProgramFiles\WindowsPowerShell\Modules\ExchangeOnlineManagement\1.0.1\" -Force -Confirm:$false -EA stop 
        } catch { Write-host "Error: $($Error[0].Exception.Message)" -F yellow }}
        } Else { Write-host "ExchangeOnlineManagement - Version $((Get-Module ExchangeOnlineManagement -ListAvailable).Version) installed - OK" -F Green }
######
