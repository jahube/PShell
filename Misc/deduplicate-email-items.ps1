# source https://gallery.technet.microsoft.com/office/Removing-Duplicate-Items-f706e1cc

$user = "affected@user.com"

$Credentials = Get-Credential $user

Install-Package Exchange.WebServices.Managed.Api

cd "$ENV:ProgramFiles\PackageManagement\NuGet\Packages\Exchange.WebServices.Managed.Api.2.2.1.2\lib\net35"

$EWSDLL = 'Microsoft.Exchange.WebServices.dll'

import-module "$pwd\$EWSDLL"

wget -Uri "https://raw.githubusercontent.com/michelderooij/Remove-DuplicateItems/master/Remove-DuplicateItems.ps1" -OutFile ".\Remove-DuplicateItems.ps1"

Set-ExecutionPolicy bypass

.\Remove-DuplicateItems.ps1 -Identity $user -Credentials $Credentials