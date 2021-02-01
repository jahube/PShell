# source https://gallery.technet.microsoft.com/office/Removing-Duplicate-Items-f706e1cc
# Autor's page: https://eightwone.com/2013/06/21/removing-duplicate-items-from-a-mailbox/
#########################################################################################
# NOTE: for shared mailbox assign full access permission and put the accessing user in credentials + parameter -Impersonationb

$user = "affected@user.com"

$Credentials = Get-Credential                 

#OLD# Register-PackageSource -provider NuGet -name nugetRepository -location https://www.nuget.org/api/v2  # V2 seems deprecated use below
# unRegister-PackageSource nugetRepository

Register-PackageSource -provider NuGet -name nugetRepository -location https://api.nuget.org/v3/index.json # <-- NEW V3

get-package Exchange.WebServices.Managed.Api

Install-Package Exchange.WebServices.Managed.Api -ProviderName NuGet -source nugetRepository # -RequiredVersion 2.2.1.2

cd "$ENV:ProgramFiles\PackageManagement\NuGet\Packages\Exchange.WebServices.Managed.Api.2.2.1.2\lib\net35"

$EWSDLL = 'Microsoft.Exchange.WebServices.dll'

import-module "$pwd\$EWSDLL"

wget -Uri "https://raw.githubusercontent.com/michelderooij/Remove-DuplicateItems/master/Remove-DuplicateItems.ps1" -OutFile ".\Remove-DuplicateItems.ps1"

Set-ExecutionPolicy bypass

.\Remove-DuplicateItems.ps1 -Identity $user -Server outlook.office365.com -Credentials $Credentials -