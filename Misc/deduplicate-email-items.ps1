# source https://gallery.technet.microsoft.com/office/Removing-Duplicate-Items-f706e1cc
# Autor's page: https://eightwone.com/2013/06/21/removing-duplicate-items-from-a-mailbox/
#########################################################################################

# NOTE: for shared mailbox use parameter -Impersonation + assign full access

################### (1) Modify + Run Variables ###################

$user = "affected@user.com"

$Credentials = Get-Credential   

################ (2) Download + install + execute ################


[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Register-PSRepository -Default
Install-PackageProvider -Name NuGet

Unregister-PackageSource -Name nugetRepository
Register-PackageSource -provider NuGet -name nugetRepository -location "https://api.nuget.org/v3/index.json"
Install-Package Exchange.WebServices.Managed.Api -ProviderName NuGet -source nugetRepository

$EWSDLLPath = "$ENV:ProgramFiles\PackageManagement\NuGet\Packages\Exchange.WebServices.Managed.Api.2.2.1.2\lib\net35"
cd $EWSDLLPath ; $EWSDLL = "Microsoft.Exchange.WebServices.dll"
Import-module $EWSDLLPath\$EWSDLL

$Source = "https://raw.githubusercontent.com/michelderooij/Remove-DuplicateItems/master/Remove-DuplicateItems.ps1"
wget -Uri $Source -OutFile "$EWSDLLPath\Remove-DuplicateItems.ps1" ; Set-ExecutionPolicy bypass -force -Confirm:$false

.\Remove-DuplicateItems.ps1 -Identity "$user" -Server outlook.office365.com -Credentials $Credentials

#shared mailboxes
.\Remove-DuplicateItems.ps1 -Identity "$user" -Server outlook.office365.com -Credentials $Credentials -impersonation