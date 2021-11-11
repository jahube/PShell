# desktop/MS-Logs+Timestamp
$ts = Get-Date -Format yyyyMMdd_hhmmss
$DesktopPath = ([Environment]::GetFolderPath('Desktop'))
$logsPATH = mkdir "$DesktopPath\MS-Logs\Group_Export_$ts"

Start-Transcript "$logsPATH\Group_Export_$ts.txt"
$FormatEnumerationLimit = -1

$Groups = Get-UnifiedGroup -ResultSize unlimited

$count = $Groups.count ; $C = 0 ; $Members = @() ; [Array]$data = @()
# $data = "" | select Type,DisplayName,ExternalDirectoryObjectId,Name,Alias,PrimarySMTP,HiddenGroupMembership,HiddenFromExchangeClients,HiddenFromAddressLists,Subscription,ReportToOriginator,ReportToManager,RequireSenderAuthentication,MBX_SMTP,MBX_Alias,MBX_ExchangeGuid

foreach ($G in $Groups) {
Write-Progress -Activity "[Group - NAME]  $($G.name)  - [Group - SMTP] $($G.PrimarySmtpAddress)" -Status "Group $($C) / $($count)" -PercentComplete (($C/$count)*100) -SecondsRemaining "$($count-$C)" ;

#MBX
    Try { $MBX = @() ; $MBX = Get-Mailbox $G.ExternalDirectoryObjectId -GroupMailbox -ErrorAction stop } 
  catch { $MBX = "" | select PrimarySMTPaddress,Alias,ExchangeGuid ; $MBX.PrimarySMTPaddress = "failed" ; $MBX.Alias = "failed" ; $MBX.ExchangeGuid = "failed"
           write-host $Error[0].Exception.message -F yellow }

#MBXStats
    Try {  $MbxStats = '' ;  $MbxStats = Get-MailboxStatistics -Identity $MBX.DistinguishedName -ErrorAction stop
         # $MBX_Fstat = Get-MailboxfolderStatistics -Identity $MBX.DistinguishedName -FolderScope recoverableitems -ErrorAction stop

           $TotalItemSize = $([math]::Round(($MbxStats.TotalItemSize.ToString().Split(“(“)[1].Split(” “)[0].Replace(“,”,””)/1MB),2))
    $TotalDeletedItemSize = $([math]::Round(($MbxStats.TotalDeletedItemSize.ToString().Split(“(“)[1].Split(” “)[0].Replace(“,”,””)/1MB),2))
   $MessageTableTotalSize = $([math]::Round(($MbxStats.MessageTableTotalSize.ToString().Split(“(“)[1].Split(” “)[0].Replace(“,”,””)/1MB),2))
       $SystemMessageSize = $([math]::Round(($MbxStats.SystemMessageSize.ToString().Split(“(“)[1].Split(” “)[0].Replace(“,”,””)/1MB),2))
             $MailboxGuid = $MbxStats.MailboxGuid.guid
             $OwnerADGuid = $MbxStats.OwnerADGuid.guid  }
  catch {       $MbxStats = '' | select TotalItemSize,TotalDeletedItemSize,MessageTableTotalSize,SystemMessageSize,MailboxGuid,OwnerADGuid 
           $TotalItemSize = "failed"
    $TotalDeletedItemSize = "failed"
   $MessageTableTotalSize = "failed"
       $SystemMessageSize = "failed"
             $MailboxGuid = "failed"
             $OwnerADGuid = "failed"

           write-host $Error[0].Exception.message -F yellow }

# $item = "" | select Type,DisplayName,ExternalDirectoryObjectId,Name,Alias,PrimarySMTP,HiddenGroupMembership,HiddenFromExchangeClients,HiddenFromAddressLists,Subscription,ReportToOriginator,ReportToManager,RequireSenderAuthentication,MBX_SMTP,MBX_Alias,MBX_ExchangeGuid

$item = [PSCustomObject]@{ Type = "Group"
                    DisplayName = $G.DisplayName
      ExternalDirectoryObjectId = $G.ExternalDirectoryObjectId
                           Name = $G.Name
                          Alias = $G.Alias
                    PrimarySMTP = $G.PrimarySMTPaddress
          HiddenGroupMembership = $G.HiddenGroupMembershipEnabled
      HiddenFromExchangeClients = $G.HiddenFromExchangeClientsEnabled
         HiddenFromAddressLists = $G.HiddenFromAddressListsEnabled
                   Subscription = $G.SubscriptionEnabled
             ReportToOriginator = $G.ReportToOriginatorEnabled
                ReportToManager = $G.ReportToManagerEnabled
    RequireSenderAuthentication = $G.RequireSenderAuthenticationEnabled
                       MBX_SMTP = $MBX.PrimarySMTPaddress
                      MBX_Alias = $MBX.Alias
               MBX_ExchangeGuid = $MBX.ExchangeGuid
                  TotalItemSize = $TotalItemSize
           TotalDeletedItemSize = $TotalDeletedItemSize
          MessageTableTotalSize = $MessageTableTotalSize
              SystemMessageSize = $SystemMessageSize
                    MailboxGuid = $MailboxGuid
                    OwnerADGuid = $OwnerADGuid }

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
$Groupmembers | FT -AutoSize > "$GroupDirPath\Groupmembers-$Groupdirname.txt"

$GroupOwners = Get-UnifiedGroupLinks -Identity $G.ExternalDirectoryObjectId -LinkType Owner -ResultSize unlimited
$GroupOwners | Export-csv "$GroupDirPath\GroupOwners-$Groupdirname.CSV" -NoTypeInformation
$GroupOwners | Export-Clixml "$GroupDirPath\GroupOwners-$Groupdirname.XML"
$GroupOwners | FT -AutoSize > "$GroupDirPath\GroupOwners-$Groupdirname.txt"

$GroupSubscribers = Get-UnifiedGroupLinks -Identity $G.ExternalDirectoryObjectId -LinkType Subscriber -ResultSize unlimited
$GroupSubscribers | Export-csv "$GroupDirPath\GroupSubscribers-$Groupdirname.CSV" -NoTypeInformation
$GroupSubscribers | Export-Clixml "$GroupDirPath\GroupSubscribers-$Groupdirname.XML"
$GroupSubscribers | FT -AutoSize > "$GroupDirPath\GroupSubscribers-$Groupdirname.txt"

$C++

}

$Data | Export-csv "$logsPATH\Group-Overview.csv" -force -NoTypeInformation
$Data | Export-Clixml "$logsPATH\Group-Overview.XML"
$Data | FT -AutoSize > "$logsPATH\Group-Overview.txt"

Stop-Transcript

Compress-Archive -Path $logsPATH -DestinationPath "$logsPATH\Group_Export_$ts" -Force # Zip Logs
Invoke-Item $logsPATH # open file manager