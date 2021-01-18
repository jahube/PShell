#Teams Channel users needs latest MicrosoftTeams Version

#install Teams
Install-Module MicrosoftTeams -AllowPrerelease
@(GET-MODULE MicrosoftTeams -LISTAVAILABLE | Sort-Object VERSION -Descending)[0].VERSION
Install-Module MicrosoftTeams -AllowPrerelease -RequiredVersion "1.1.10-preview"
IMPORT-Module MicrosoftTeams -MinimumVersion 1.1.10
Install-Module MicrosoftTeams -AllowPrerelease -RequiredVersion $((GET-MODULE MicrosoftTeams -LISTAVAILABLE | Sort-Object VERSION -Descending)[0]).Version.ToString() -Repository PsTestGallery
Uninstall-Module MicrosoftTeams -MaximumVersion $((GET-MODULE MicrosoftTeams -LISTAVAILABLE | Sort-Object VERSION -Descending)[1]).Version.ToString() -Force

#install EXO
Install-Module Exchangeonlinemanagement

#connect
$cred = get-credential
Connect-MicrosoftTeams -Credential $cred
Connect-ExchangeOnline -Credential $cred
#Get-PSSession | Remove-PSSession #(clear expired sessions)

# check groups to know the valid Group data

Get-UnifiedGroup | FT name,displayname,primarySMTPaddress,ExternalDirectoryObjectId,HiddenFromAddressListsEnabled,HiddenFromExchangeClientsEnabled
Get-Team | FT MailNickName,DisplayName,GroupId,Visibility,Description

# SHORT

Start-Transcript
# use GROUP Alias or TEAM Mailnickname
Get-Team -MailNickName "Alias / Mailnickname" | Get-Teamchannel

$team = Get-Team -MailNickName "PhysicalScience"
$channels = Get-Teamchannel -GroupId $team.GroupId
Foreach ($channel in $channels) { 
write-host "`n`n[TEAM]" $team.DisplayName "  [CHANNEL] " $channel.DisplayName -F Yellow

Get-TeamChannelUser -GroupId $team.GroupId -DisplayName $channel.DisplayName }
Stop-Transcript

# EXTENDED

# (1) ALL > TEAMS < GROUPS
$AllTeams = Get-Team
$groups = foreach ($AT in $AllTeams) { Get-UnifiedGroup $($AT.GroupID) }

# (2) ONE GROUP
$groups = Get-UnifiedGroup -Identity "group1"

# (3) selected GROUPS
$Groupnames = "group1","group2","group3"
$groups = $Groupnames | % { Get-UnifiedGroup -Identity $_ }

# desktop/MS-Logs+Timestamp
$ts = Get-Date -Format yyyyMMdd_hhmmss
$DesktopPath = ([Environment]::GetFolderPath('Desktop'))
$logsPATH = mkdir "$DesktopPath\MS-Logs\Teams-Group-Channel_LOGS_$ts"

Start-Transcript "$logsPATH\Teams-Group-Channel_LOGS_$ts.txt"
$FormatEnumerationLimit = -1

#$Groups = get-unifiedgroup -ResultSize unlimited

$data = @()
foreach ($G in $Groups) { 
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

#Team
Try { $teams = Get-Team -GroupId $G.ExternalDirectoryObjectId -ErrorAction stop 
} catch { write-host $Error[0].Exception.message -F yellow }

$Groupdirname = $($G.Alias).Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
$GroupDirPath = mkdir "$logsPATH\$Groupdirname"
$item | FL > "$GroupDirPath\Group-short-$Groupdirname.txt"
$G | FL > "$GroupDirPath\Group-Long-$Groupdirname.txt"

$Groupmembers = Get-UnifiedGroupLinks -Identity $G.ExternalDirectoryObjectId -LinkType Member
$Groupmembers | Export-csv "$GroupDirPath\Groupmembers-$Groupdirname.CSV" -NoTypeInformation
$Groupmembers | Export-Clixml "$GroupDirPath\Groupmembers-$Groupdirname.XML"
$Groupmembers | FT > "$GroupDirPath\Groupmembers-$Groupdirname.txt"

$GroupOwners = Get-UnifiedGroupLinks -Identity $G.ExternalDirectoryObjectId -LinkType Owner
$GroupOwners | Export-csv "$GroupDirPath\GroupOwners-$Groupdirname.CSV" -NoTypeInformation
$GroupOwners | Export-Clixml "$GroupDirPath\GroupOwners-$Groupdirname.XML"
$GroupOwners | FT > "$GroupDirPath\GroupOwners-$Groupdirname.txt"

IF ($teams) { 

$teams | Export-csv "$GroupDirPath\TEAM-$Groupdirname.CSV" -NoTypeInformation
$teams | Export-Clixml "$GroupDirPath\TEAM-$Groupdirname.XML"
$teams | FL > "$GroupDirPath\TEAM-$Groupdirname.txt"

#$teams | Export-csv "$GroupDirPath\TEAM-$($T.MailNickName).Csv" -NoTypeInformation
#$teams | Export-Clixml "$GroupDirPath\TEAM-$($T.MailNickName).Xml"
#$teams | FL > "$GroupDirPath\TEAM-$($T.MailNickName).Txt"

foreach ($T in $teams) {

Try { $channel = Get-TeamChannel -GroupId $T.GroupId -ErrorAction stop } catch { write-host $Error[0].Exception.message -F yellow }

If ($channel) {

$channel | FL > "$GroupDirPath\ChannelLIST-$Groupdirname.txt"
$channel | Export-csv "$GroupDirPath\ChannelLIST-$Groupdirname.CSV" -NoTypeInformation
#$channel | Export-csv "$GroupDirPath\ChannelLIST-$($T.MailNickName).Csv" -NoTypeInformation
#$channel | FL > "$GroupDirPath\ChannelLIST-$($T.MailNickName).Txt"

Foreach ($C in $channel) {

$channelusers = try { Get-TeamChannelUser -GroupId $T.GroupId -DisplayName $C.DisplayName } catch { Get-TeamChannelUser -GroupId $G.ExternalDirectoryObjectId -DisplayName $C.DisplayName }
$channelOwners = Get-TeamChannelUser -GroupId $G.ExternalDirectoryObjectId -DisplayName $C.DisplayName -Role Owner
$channelMembers = Get-TeamChannelUser -GroupId $G.ExternalDirectoryObjectId -DisplayName $C.DisplayName -Role Member

$Channelpathname = 'CHANNEL_' + $($C.DisplayName)
$ChannelPath = $Channelpathname.Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
$ChannelDirPath = mkdir "$logsPATH\$Groupdirname\$ChannelPath"

$channelusers | Export-csv "$ChannelDirPath\USERS-Channel-$($C.DisplayName).CSV" -NoTypeInformation
#$channelusers | Export-Clixml "$ChannelDirPath\USERS-Channel-$($C.DisplayName).XML"
$channelusers | FT > "$ChannelDirPath\USERS-Channel-$($C.DisplayName).txt"

$channelOwners | Export-csv "$ChannelDirPath\OWNERS-Channel-$($C.DisplayName).CSV" -NoTypeInformation
#$channelOwners | Export-Clixml "$ChannelDirPath\OWNERS-Channel-$($C.DisplayName).XML"
$channelOwners | FT > "$ChannelDirPath\OWNERS-Channel-$($C.DisplayName).txt"
} }}}}

Stop-Transcript
###### END TRANSCRIPT ######################
$destination = "$DesktopPath\MS-Logs\Teams-Group-Channel_LOGS_$ts.zip"
Add-Type -assembly “system.io.compression.filesystem”
[io.compression.zipfile]::CreateFromDirectory($logsPATH, $destination) # ZIP
Invoke-Item $DesktopPath\MS-Logs # open file manager
###### END ZIP Logs ########################
