# source https://gallery.technet.microsoft.com/office/Removing-Duplicate-Items-f706e1cc
# Autor's page: https://eightwone.com/2013/06/21/removing-duplicate-items-from-a-mailbox/
#########################################################################################
# NOTE: for shared mailbox assign full access permission and put the accessing user in credentials + parameter -Impersonationb

$user = "affected@user.com"

$Credentials = Get-Credential   

$Path = "$ENV:USERPROFILE\Downloads"
# Alternative: $Path = "$ENV:USERPROFILE\Documents\WindowsPowerShell\Modules / $Path = $ENV:ProgramFiles\WindowsPowerShell\Modules

$Source = "https://raw.githubusercontent.com/michelderooij/Remove-DuplicateItems/master/Remove-DuplicateItems.ps1"

# unRegister-PackageSource nugetRepository # get-package Exchange.WebServices.Managed.Api
Register-PackageSource -provider NuGet -name nugetRepository -location https://api.nuget.org/v3/index.json         # <-- NEW V3

Install-Package Exchange.WebServices.Managed.Api -ProviderName NuGet -source nugetRepository                       # -RequiredVersion 2.2.1.2

Import-module "$ENV:ProgramFiles\PackageManagement\NuGet\Packages\Exchange.WebServices.Managed.Api.2.2.1.2\lib\net35\Microsoft.Exchange.WebServices.dll"

wget -Uri $Source -OutFile "$Path\Remove-DuplicateItems.ps1"

Set-ExecutionPolicy bypass

$Path\Remove-DuplicateItems.ps1 -Identity $user -Server outlook.office365.com -Credentials $Credentials

# use the following Parameter: -Impersonation #for shared mailbox /+ full access to $credential user

# $Path\Remove-DuplicateItems.ps1 -Identity $user -Server outlook.office365.com -Credentials $Credentials -IncludeFolders '#Inbox#\*','#Calendar#\*','#SentItems#\*','#Contacts#\* -ExcludeFolders '#JunkEmail#\*','#DeletedItems#\*' -PriorityFolders '#Inbox#\*'

# CD /D $Path
# .\Remove-DuplicateItems.ps1 -Identity $user -Server outlook.office365.com -Credentials $Credentials # -Impersonation #for shared mailbox /+ full access to $credential user

# #WellKnownFolderName#, '#Calendar#\*','#Contacts#\*','#Inbox#\*','#Notes#\*','#SentItems#\*','#Tasks#\*','#JunkEmail#\*','#DeletedItems#\*'
# -Type mail,calendar,contacts
# -DeleteMode SoftDelete, MoveToDeletedItems
