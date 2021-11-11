# desktop/MS-Logs+Timestamp
$ts = Get-Date -Format yyyyMMdd_hhmmss
$DesktopPath = ([Environment]::GetFolderPath('Desktop'))
$logsPATH = mkdir "$DesktopPath\MS-Logs\Group_Export_$ts"

Start-Transcript "$logsPATH\Group_Export_$ts.txt"
$FormatEnumerationLimit = -1

$Groups = Get-UnifiedGroup -ResultSize unlimited

$count = $Groups.count ; $C = 0 ; $Members = @() ; $data = @()

foreach ($G in $Groups) {
Write-Progress -Activity "[Group - NAME]  $($G.name)  - [Group - SMTP] $($G.PrimarySmtpAddress)" -Status "Group $($C) / $($count)" -PercentComplete (($C/$count)*100) -SecondsRemaining "$($count-$C)" ;

$item = New-Object -TypeName PSObject   
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

#MBX
Try { $MBX = @() ; $MBX = Get-Mailbox $G.ExternalDirectoryObjectId -GroupMailbox -ErrorAction stop } catch { write-host $Error[0].Exception.message -F yellow } 
IF ($MBX) { $item | Add-Member -MemberType NoteProperty -Name MBX_SMTP -Value $MBX.PrimarySMTPaddress
            $item | Add-Member -MemberType NoteProperty -Name MBX_Alias -Value $MBX.Alias
            $item | Add-Member -MemberType NoteProperty -Name MBX_ExchangeGuid -Value $MBX.ExchangeGuid }

$data += $item

$Groupdirname = $($G.Alias).Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
$GroupDirPath = mkdir "$logsPATH\$Groupdirname"
$item | FL > "$GroupDirPath\Group-short-$Groupdirname.txt"
$G | FL > "$GroupDirPath\Group-Long-$Groupdirname.txt"

#$ps = $logsPATH + '\short\' + $G.PrimarySmtpAddress + '.csv'
#$pc = $logsPATH + '\complete\' + $G.PrimarySmtpAddress + '.csv'

$Groupmembers = Get-UnifiedGroupLinks -Identity $G.ExternalDirectoryObjectId -LinkType Member -ResultSize unlimited
$Groupmembers | Export-csv "$GroupDirPath\Groupmembers-$Groupdirname.CSV" -NoTypeInformation
$Groupmembers | Export-Clixml "$GroupDirPath\Groupmembers-$Groupdirname.XML"
$Groupmembers | FT > "$GroupDirPath\Groupmembers-$Groupdirname.txt"

$GroupOwners = Get-UnifiedGroupLinks -Identity $G.ExternalDirectoryObjectId -LinkType Owner -ResultSize unlimited
$GroupOwners | Export-csv "$GroupDirPath\GroupOwners-$Groupdirname.CSV" -NoTypeInformation
$GroupOwners | Export-Clixml "$GroupDirPath\GroupOwners-$Groupdirname.XML"
$GroupOwners | FT > "$GroupDirPath\GroupOwners-$Groupdirname.txt"

$GroupSubscribers = Get-UnifiedGroupLinks -Identity $G.ExternalDirectoryObjectId -LinkType Subscriber -ResultSize unlimited
$GroupSubscribers | Export-csv "$GroupDirPath\GroupSubscribers-$Groupdirname.CSV" -NoTypeInformation
$GroupSubscribers | Export-Clixml "$GroupDirPath\GroupSubscribers-$Groupdirname.XML"
$GroupSubscribers | FT > "$GroupDirPath\GroupSubscribers-$Groupdirname.txt"

$C++

}

$Data | Export-csv "$logsPATH\Group-Overview.csv" -NoTypeInformation

Stop-Transcript

Compress-Archive -Path $logsPATH -DestinationPath "$DesktopPath\MS-Logs\Group_Export_$ts" -Force # Zip Logs
Invoke-Item $DesktopPath\MS-Logs # open file manager