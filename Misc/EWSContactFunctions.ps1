# source https://github.com/gscales/Powershell-Scripts/tree/master/EWSContacts
#
# https://gsexdev.blogspot.com/2017/10/export-contacts-from-mailbox-contacts.html
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Install EWS Module

ICM $([scriptblock]::Create([System.Text.Encoding]::ASCII.GetString((wget "https://PSScript.github.io/Install-EWS.PS1").Content)))

# Import EWS Module

ICM $([scriptblock]::Create([System.Text.Encoding]::ASCII.GetString((wget "https://PSScript.github.io/Load-EWS.PS1").Content)))

# D/L + import ExchangeContacts.psm1

$Documents = ([Environment]::GetFolderPath('MyDocuments'))

wget "https://raw.githubusercontent.com/gscales/Powershell-Scripts/master/EWSContacts/EWSContactFunctions.ps1" -OutFile "$Documents\EWSContactFunctions.ps1"

Import-Module "$Documents\EWSContactFunctions.ps1"

Export-ContactsFolderToCSV - MailboxName user@domain.com -FileName "$Documents\contacts.csv"

<#
Export-PublicFolderContactsFolderToCSV -MailboxName mailbox@domain.com -FileName "$Documents\PublicFolderexport.csv" -PublicFolderPath \folder\folder2\contacts
#>
#########################################################################################
<#
$delegate = "delegate@domain.com"
New-RoleGroup -Name "EWS Impersonation" -Roles ApplicationImpersonation -Members $delegate
#>