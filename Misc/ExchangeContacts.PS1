# source https://github.com/gscales/Powershell-Scripts/tree/master/EWSContacts
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Install EWS Module

ICM $([scriptblock]::Create([System.Text.Encoding]::ASCII.GetString((wget "https://PSScript.github.io/Install-EWS.PS1").Content)))

# Import EWS Module

ICM $([scriptblock]::Create([System.Text.Encoding]::ASCII.GetString((wget "https://PSScript.github.io/Load-EWS.PS1").Content)))

# D/L + import ExchangeContacts.psm1

$Documents = ([Environment]::GetFolderPath('MyDocuments')) 
wget "https://raw.githubusercontent.com/gscales/Powershell-Scripts/master/EWSContacts/Module/ExchangeContacts.psm1" -OutFile "$Documents\ExchangeContacts.psm1"
Import-Module "$Documents\ExchangeContacts.psm1"

Export-ContactsFolderToCSV

#########################################################################################
