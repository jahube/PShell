# https://raw.githubusercontent.com/jahube/PShell/master/Misc/SCAN-CONTACTS1.ps1
# source https://gallery.technet.microsoft.com/office/Removing-Duplicate-Items-f706e1cc

$user = "affected@mailbox.com"
$Credentials = Get-Credential $user
$Path = "$ENV:USERPROFILE\Downloads"

Register-PackageSource -provider NuGet -name nugetRepository -location https://api.nuget.org/v3/index.json 
Install-Package Exchange.WebServices.Managed.Api -ProviderName NuGet -source nugetRepository
Import-module "$ENV:ProgramFiles\PackageManagement\NuGet\Packages\Exchange.WebServices.Managed.Api.2.2.1.2\lib\net35\Microsoft.Exchange.WebServices.dll"

$Source = "https://raw.githubusercontent.com/jahube/PShell/master/Misc/SCAN-CONTACTS1.ps1"
wget -Uri $Source -OutFile "$Path\SCAN-CONTACTS1.ps1" ; Set-ExecutionPolicy bypass ; CD /D $Path ;

$Path\SCAN-CONTACTS1.ps1 -Identity $user -Credentials $Credentials -Mode Full

$pathout = mkdir "C:\TempContacts" -force

# $global:searchedEWScontacts = @()
# $global:SearchedEWSemails = @()
$global:searchedEWScontacts |ft DisplayName
$global:SearchedEWSemails | Ft Name,Address

$Searchedemails = $global:SearchedEWSemails | Select-Object Name,Address -Unique

$Searchedemails | Export-Csv $pathout\EmailsExported.CSV -NoTypeInformation

$global:searchedEWScontacts |  Export-Csv $pathout\contactsExported.CSV -NoTypeInformation

$global:searchedEWScontacts | Select FileAs,DisplayName,GivenName,Initials,MiddleName,NickName,CompanyName | Export-Csv $pathout\contactsShortOverview.CSV -NoTypeInformation