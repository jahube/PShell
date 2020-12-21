# https://raw.githubusercontent.com/jahube/PShell/master/Misc/SCAN-CONTACTS1.ps1
# source https://gallery.technet.microsoft.com/office/Removing-Duplicate-Items-f706e1cc

$user = "affected@mailbox.com"
$Credentials = Get-Credential $user

Register-PackageSource -provider NuGet -name nugetRepository -location https://www.nuget.org/api/v2

Install-Package Exchange.WebServices.Managed.Api

cd "$ENV:ProgramFiles\PackageManagement\NuGet\Packages\Exchange.WebServices.Managed.Api.2.2.1.2\lib\net35"

$EWSDLL = 'Microsoft.Exchange.WebServices.dll'
import-module "$pwd\$EWSDLL"


wget -Uri "https://raw.githubusercontent.com/jahube/PShell/master/Misc/SCAN-CONTACTS1.ps1" -OutFile ".\SCAN-CONTACTS1.ps1"

Set-ExecutionPolicy bypass -Confirm:$false -Force

.\SCAN-CONTACTS1.ps1 -Identity $user -Credentials $Credentials -Mode Full
$path = mkdir "C:\TempContacts"

# $global:searchedEWScontacts = @()
# $global:SearchedEWSemails = @()
$global:searchedEWScontacts |ft DisplayName
$global:SearchedEWSemails | Ft Name,Address

$Searchedemails = $global:SearchedEWSemails | Select-Object Name,Address -Unique

$Searchedemails | Export-Csv $path\EmailsExported.CSV -NoTypeInformation

$global:searchedEWScontacts |  Export-Csv $path\contactsExported.CSV -NoTypeInformation

$global:searchedEWScontacts | Select FileAs,DisplayName,GivenName,Initials,MiddleName,NickName,CompanyName | Export-Csv $path\contactsShortOverview.CSV -NoTypeInformation