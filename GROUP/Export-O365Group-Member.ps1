# desktop/MS-Logs+Timestamp
$ts = Get-Date -Format yyyyMMdd_hhmmss
$DesktopPath = ([Environment]::GetFolderPath('Desktop'))
$logsPATH = mkdir "$DesktopPath\MS-Logs\Group_Export_$ts"

Start-Transcript "$logsPATH\Group_Export_$ts.txt"
$FormatEnumerationLimit = -1

$Groups = Get-UnifiedGroup -ResultSize unlimited

$count = $Groups.count ; $C = 0 ; $Members = @() ; $data = @()

foreach ($G in $Groups) {
Write-Progress -Activity "Group $($DL.name) $($DL.userprincipalname)" -Status "Group $($C) / $($count)" -PercentComplete (($C/$count)*100) -SecondsRemaining "$($count-$C)" ;

$ps = $path + '\short\' + $DL.PrimarySmtpAddress + '.csv'
$pc = $path + '\complete\' + $DL.PrimarySmtpAddress + '.csv'

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

#MBX
Try { $MBX = @() ; $MBX = Get-Mailbox $G.ExternalDirectoryObjectId -GroupMailbox -ErrorAction stop } catch { write-host $Error[0].Exception.message -F yellow } 
IF ($MBX) { $item | Add-Member -MemberType NoteProperty -Name MBXSMTP -Value $MBX.PrimarySMTPaddress
            $item | Add-Member -MemberType NoteProperty -Name MBXAlias -Value $MBX.Alias }
$data += $item

$Groupdirname = $($G.Alias).Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
$GroupDirPath = mkdir "$logsPATH\$Groupdirname"
$item | FL > "$GroupDirPath\Group-short-$Groupdirname.txt"
$item | Export-csv "$GroupDirPath\Group-$Groupdirname-custom.csv" -NoTypeInformation
$G | FL > "$GroupDirPath\Group-Long-$Groupdirname.txt"

$Groupmembers = Get-UnifiedGroupLinks -Identity $G.ExternalDirectoryObjectId -LinkType Member
$Groupmembers | Export-csv "$GroupDirPath\Groupmembers-$Groupdirname.CSV" -NoTypeInformation
$Groupmembers | Export-Clixml "$GroupDirPath\Groupmembers-$Groupdirname.XML"
$Groupmembers | FT > "$GroupDirPath\Groupmembers-$Groupdirname.txt"

$GroupOwners = Get-UnifiedGroupLinks -Identity $G.ExternalDirectoryObjectId -LinkType Owner
$GroupOwners | Export-csv "$GroupDirPath\GroupOwners-$Groupdirname.CSV" -NoTypeInformation
$GroupOwners | Export-Clixml "$GroupDirPath\GroupOwners-$Groupdirname.XML"
$GroupOwners | FT > "$GroupDirPath\GroupOwners-$Groupdirname.txt"


$Groupmembers = Get-UnifiedGroupLinks -Identity $G.ExternalDirectoryObjectId -LinkType Member -ResultSize unlimited
$Groupmembers | Export-csv "$GroupDirPath\Groupmembers-$Groupdirname.CSV" -NoTypeInformation
$Groupmembers | Export-Clixml "$GroupDirPath\Groupmembers-$Groupdirname.XML"
$Groupmembers | FT > "$GroupDirPath\Groupmembers-$Groupdirname.txt"

$GroupOwners = Get-UnifiedGroupLinks -Identity $G.ExternalDirectoryObjectId -LinkType Owner -ResultSize unlimited
$GroupOwners | Export-csv "$GroupDirPath\GroupOwners-$Groupdirname.CSV" -NoTypeInformation
$GroupOwners | Export-Clixml "$GroupDirPath\GroupOwners-$Groupdirname.XML"
$GroupOwners | FT > "$GroupDirPath\GroupOwners-$Groupdirname.txt"

$GroupOwners = Get-UnifiedGroupLinks -Identity $G.ExternalDirectoryObjectId -LinkType Subscriber -ResultSize unlimited
$GroupOwners | Export-csv "$GroupDirPath\GroupSubscriber-$Groupdirname.CSV" -NoTypeInformation
$GroupOwners | Export-Clixml "$GroupDirPath\GroupSubscriber-$Groupdirname.XML"
$GroupOwners | FT > "$GroupDirPath\GroupSubscriber-$Groupdirname.txt"


$C++

}

Stop-Transcript

Compress-Archive -Path $logsPATH -DestinationPath "$DesktopPath\MS-Logs\Group_Export_$ts" -Force # Zip Logs
Invoke-Item $DesktopPath\MS-Logs # open file manager