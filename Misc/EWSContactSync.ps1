# https://github.com/grahamr975/EWS-Office365-Contact-Sync/blob/master/EWSContactSync.ps1
# https://github.com/grahamr975/EWS-Office365-Contact-Sync

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Install EWS Module

ICM $([scriptblock]::Create([System.Text.Encoding]::ASCII.GetString((wget "https://PSScript.github.io/Install-EWS.PS1").Content)))

# Import EWS Module

ICM $([scriptblock]::Create([System.Text.Encoding]::ASCII.GetString((wget "https://PSScript.github.io/Load-EWS.PS1").Content)))

# D/L + import ExchangeContacts.psm1

$Documents = ([Environment]::GetFolderPath('MyDocuments')) 
wget "https://raw.githubusercontent.com/grahamr975/EWS-Office365-Contact-Sync/master/EWSContactSync.ps1" -OutFile "$Documents\EWSContactSync.ps1"
. .\"$Documents\EWSContactSync.ps1"

#########################################################################################
