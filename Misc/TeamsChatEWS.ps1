# The below is only the EWS loading routine for the scripts under the below links
# https://gsexdev.blogspot.com/2020/12/getting-teams-chat-history-messages.html
# https://github.com/gscales/Powershell-Scripts/blob/master/GetTeamsChatMessages.ps1
# https://github.com/gscales/TeamsChatHistoryOWAAddIn
# alternative https://techcommunity.microsoft.com/t5/windows-powershell/script-for-teams-chat-backup/m-p/1547371

$user = "affected@user.com"

$Credentials = Get-Credential $user

#OLD# Register-PackageSource -provider NuGet -name nugetRepository -location https://www.nuget.org/api/v2  # V2 seems deprecated use below
# unRegister-PackageSource nugetRepository

Register-PackageSource -provider NuGet -name nugetRepository -location https://api.nuget.org/v3/index.json # <-- NEW V3

get-package Exchange.WebServices.Managed.Api

Install-Package Exchange.WebServices.Managed.Api -ProviderName NuGet -source nugetRepository # -RequiredVersion 2.2.1.2

cd "$ENV:ProgramFiles\PackageManagement\NuGet\Packages\Exchange.WebServices.Managed.Api.2.2.1.2\lib\net35"

$EWSDLL = 'Microsoft.Exchange.WebServices.dll'

import-module "$pwd\$EWSDLL"

wget -Uri "https://raw.githubusercontent.com/gscales/Powershell-Scripts/master/GetTeamsChatMessages.ps1" -OutFile ".\Get-TeamsChatMessages.ps1"

Set-ExecutionPolicy bypass

import-module .\Get-TeamsChatMessages.ps1

# OR . .\Get-TeamsChatMessages.ps1

Get-TeamsChatMessages -mailboxname $user | select DateTimeReceived,Body