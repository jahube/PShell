# source https://gallery.technet.microsoft.com/office/Removing-Duplicate-Items-f706e1cc

$user = "affected@user.com"

$Credentials = Get-Credential $user

Register-PackageSource -provider NuGet -name nugetRepository -location https://www.nuget.org/api/v2

Install-Package Exchange.WebServices.Managed.Api

cd "$ENV:ProgramFiles\PackageManagement\NuGet\Packages\Exchange.WebServices.Managed.Api.2.2.1.2\lib\net35"

$EWSDLL = 'Microsoft.Exchange.WebServices.dll'

import-module "$pwd\$EWSDLL"

wget -Uri "https://raw.githubusercontent.com/michelderooij/Remove-DuplicateItems/master/Remove-DuplicateItems.ps1" -OutFile ".\Remove-DuplicateItems.ps1"

Set-ExecutionPolicy bypass

.\Remove-DuplicateItems.ps1 -Identity $user -Server outlook.office365.com -Credentials $Credentials