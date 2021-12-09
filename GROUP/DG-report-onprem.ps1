# desktop/MS-Logs+Timestamp
$ts = Get-Date -Format yyyyMMdd_hhmmss
$DesktopPath = ([Environment]::GetFolderPath('Desktop'))
$logsPATH = mkdir "$DesktopPath\MS-Logs\Group_Export_$ts"

$CSV = ','

$join = ';'

Start-Transcript "$logsPATH\Group_Export_$ts.txt"
$FormatEnumerationLimit = -1

#Set-ADServerSettings -ViewEntireForest $true

$Groups = Get-distributiongroup -ResultSize unlimited # -ReadFromDomainController DC1

$count = $Groups.count ; $C = 0 ; $Members = @() ; [Array]$data = @()

foreach ($G in $Groups) {
Write-Progress -Activity "[Group - NAME]  $($G.name)  - [Group - SMTP] $($G.PrimarySmtpAddress)" -Status "Group $($C) / $($count)" -PercentComplete (($C/$count)*100) -SecondsRemaining "$($count-$C)" ;

$item = New-Object -TypeName PSCustomObject  
$item | Add-Member -MemberType NoteProperty -Name Type -Value "Group"
$item | Add-Member -MemberType NoteProperty -Name DisplayName -Value $G.DisplayName
$item | Add-Member -MemberType NoteProperty -Name ExternalDirectoryObjectId -Value $G.ExternalDirectoryObjectId
$item | Add-Member -MemberType NoteProperty -Name Name -Value $G.Name
$item | Add-Member -MemberType NoteProperty -Name Alias -Value $G.Alias
$item | Add-Member -MemberType NoteProperty -Name PrimarySMTP -Value $G.PrimarySMTPaddress
$item | Add-Member -MemberType NoteProperty -Name HiddenGroupMembership -Value $G.HiddenGroupMembershipEnabled
$item | Add-Member -MemberType NoteProperty -Name HiddenFromExchangeClients -Value $G.HiddenFromExchangeClientsEnabled
$item | Add-Member -MemberType NoteProperty -Name HiddenFromAddressLists -Value $G.HiddenFromAddressListsEnabled
$item | Add-Member -MemberType NoteProperty -Name Subscription -Value $G.SubscriptionEnabled
$item | Add-Member -MemberType NoteProperty -Name ReportToOriginator -Value $G.ReportToOriginatorEnabled
$item | Add-Member -MemberType NoteProperty -Name ReportToManager -Value $G.ReportToManagerEnabled
$item | Add-Member -MemberType NoteProperty -Name RequireSenderAuthentication -Value $G.RequireSenderAuthenticationEnabled
$item | Add-Member -MemberType NoteProperty -Name Managedby -Value "$($G.Managedby -join $join)"
$item | Add-Member -MemberType NoteProperty -Name DistinguishedName -Value $G.DistinguishedName
$item | Add-Member -MemberType NoteProperty -Name SamAccountName -Value $G.SamAccountName
$item | Add-Member -MemberType NoteProperty -Name SimpleDisplayName -Value $G.SimpleDisplayName

#$item | Add-Member -MemberType NoteProperty -Name Manager -Value $G.Manager
#$item | Add-Member -MemberType NoteProperty -Name City -Value $G.City
#$item | Add-Member -MemberType NoteProperty -Name Office -Value $G.Office
#$item | Add-Member -MemberType NoteProperty -Name Company -Value $G.Company

}

$data += $item

$Groupdirname = $($G.Alias).Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
$GroupDirPath = mkdir "$logsPATH\$Groupdirname"
$item | FL > "$GroupDirPath\Group-short-$Groupdirname.txt"
$G | FL > "$GroupDirPath\Group-Long-$Groupdirname.txt"

#$ps = $logsPATH + '\short\' + $G.PrimarySmtpAddress + '.csv'
#$pc = $logsPATH + '\complete\' + $G.PrimarySmtpAddress + '.csv'
# desktop/MS-Logs+Timestamp
$ts = Get-Date -Format yyyyMMdd_hhmmss
$DesktopPath = ([Environment]::GetFolderPath('Desktop'))
$logsPATH = mkdir "$DesktopPath\MS-Logs\Group_Export_$ts"

$CSV = ','

$join = ';'

Start-Transcript "$logsPATH\Group_Export_$ts.txt"
$FormatEnumerationLimit = -1

#Set-ADServerSettings -ViewEntireForest $true

$Groups = Get-distributiongroup -ResultSize unlimited # -ReadFromDomainController DC1

$count = $Groups.count ; $C = 0 ; $Members = @() ; [Array]$data = @()

foreach ($G in $Groups) {
Write-Progress -Activity "[Group - NAME]  $($G.name)  - [Group - SMTP] $($G.PrimarySmtpAddress)" -Status "Group $($C) / $($count)" -PercentComplete (($C/$count)*100) -SecondsRemaining "$($count-$C)" ;

$item = New-Object -TypeName PSCustomObject  
$item | Add-Member -MemberType NoteProperty -Name Type -Value "Group"
$item | Add-Member -MemberType NoteProperty -Name DisplayName -Value $G.DisplayName
$item | Add-Member -MemberType NoteProperty -Name ExternalDirectoryObjectId -Value $G.ExternalDirectoryObjectId
$item | Add-Member -MemberType NoteProperty -Name Name -Value $G.Name
$item | Add-Member -MemberType NoteProperty -Name Alias -Value $G.Alias
$item | Add-Member -MemberType NoteProperty -Name PrimarySMTP -Value $G.PrimarySMTPaddress
$item | Add-Member -MemberType NoteProperty -Name HiddenGroupMembership -Value $G.HiddenGroupMembershipEnabled
$item | Add-Member -MemberType NoteProperty -Name HiddenFromExchangeClients -Value $G.HiddenFromExchangeClientsEnabled
$item | Add-Member -MemberType NoteProperty -Name HiddenFromAddressLists -Value $G.HiddenFromAddressListsEnabled
$item | Add-Member -MemberType NoteProperty -Name Subscription -Value $G.SubscriptionEnabled
$item | Add-Member -MemberType NoteProperty -Name ReportToOriginator -Value $G.ReportToOriginatorEnabled
$item | Add-Member -MemberType NoteProperty -Name ReportToManager -Value $G.ReportToManagerEnabled
$item | Add-Member -MemberType NoteProperty -Name RequireSenderAuthentication -Value $G.RequireSenderAuthenticationEnabled
$item | Add-Member -MemberType NoteProperty -Name Managedby -Value "$($G.Managedby -join $join)"
$item | Add-Member -MemberType NoteProperty -Name DistinguishedName -Value $G.DistinguishedName
$item | Add-Member -MemberType NoteProperty -Name SamAccountName -Value $G.SamAccountName
$item | Add-Member -MemberType NoteProperty -Name SimpleDisplayName -Value $G.SimpleDisplayName

#$item | Add-Member -MemberType NoteProperty -Name Manager -Value $G.Manager
#$item | Add-Member -MemberType NoteProperty -Name City -Value $G.City
#$item | Add-Member -MemberType NoteProperty -Name Office -Value $G.Office
#$item | Add-Member -MemberType NoteProperty -Name Company -Value $G.Company

}

$data += $item

$Groupdirname = $($G.Alias).Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
$GroupDirPath = mkdir "$logsPATH\$Groupdirname"
$item | FL > "$GroupDirPath\Group-short-$Groupdirname.txt"
$G | FL > "$GroupDirPath\Group-Long-$Groupdirname.txt"

#$ps = $logsPATH + '\short\' + $G.PrimarySmtpAddress + '.csv'
#$pc = $logsPATH + '\complete\' + $G.PrimarySmtpAddress + '.csv'


$Groupmembers = Get-distributiongroupmember -Identity $G.DistinguishedName -ResultSize unlimited
$Groupmembers | Export-csv "$GroupDirPath\Groupmembers-$Groupdirname.CSV" -NTI -Delimiter $CSV -Encoding UTF8
$Groupmembers | Export-Clixml "$GroupDirPath\Groupmembers-$Groupdirname.XML"
$Groupmembers | FT > "$GroupDirPath\Groupmembers-$Groupdirname.txt"


$C++



$Data | Export-csv "$logsPATH\Group-Overview.csv" -force -NTI -Delimiter $CSV -Encoding UTF8
$Data | Export-Clixml "$logsPATH\Group-Overview.XML"
$Data | FT -AutoSize > "$logsPATH\Group-Overview.txt"

Stop-Transcript

Compress-Archive -Path $logsPATH -DestinationPath "$logsPATH\Group_Export_$ts" -Force # Zip Logs
Invoke-Item $logsPATH # open file manager

$Groupmembers = Get-distributiongroupmember -Identity $G.DistinguishedName -ResultSize unlimited
$Groupmembers | Export-csv "$GroupDirPath\Groupmembers-$Groupdirname.CSV" -NTI -Delimiter $CSV -Encoding UTF8
$Groupmembers | Export-Clixml "$GroupDirPath\Groupmembers-$Groupdirname.XML"
$Groupmembers | FT > "$GroupDirPath\Groupmembers-$Groupdirname.txt"

$C++


$Data | Export-csv "$logsPATH\Group-Overview.csv" -force -NTI -Delimiter $CSV -Encoding UTF8
$Data | Export-Clixml "$logsPATH\Group-Overview.XML"
$Data | FT -AutoSize > "$logsPATH\Group-Overview.txt"

Stop-Transcript

Compress-Archive -Path $logsPATH -DestinationPath "$logsPATH\Group_Export_$ts" -Force # Zip Logs
Invoke-Item $logsPATH # open file manager