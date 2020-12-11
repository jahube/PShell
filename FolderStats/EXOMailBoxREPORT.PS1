$path = "C:\results.csv"
# NEW - MBX stats all users
$mbxs = Get-EXOMailbox -ResultSize Unlimited 
[System.Collections.ArrayList]$MBX = $mbxs.userprincipalname ; $DATA = @()
for ($M = 0; $M -lt $MBX.count; $M++) { $S =" [MBX] ($($M+1)/$count)  [Time]"
$A = "collecting stats [Mailbox Count] ($($M+1)/$count) [Mailbox] $($MBX[$M])"
Write-Progress -Activity $A -Status $S -PercentComplete (($M/$count)*100) -SecondsRemaining ($count-$M) ;
$mbxitem = icm { get-EXOmailbox $($MBX[$M]) }
$mbxstats = icm { Get-EXOMailboxStatistics $($MBX[$M]) }
$RECitem = icm { (Get-EXOMailboxFolderStatistics -Identity $($MBX[$M]) -folderscope recoverableitems).where( { $_.FolderType -eq "RecoverableItemsRoot"} ) }
$itemLNG = icm { Get-MailboxRegionalConfiguration $($MBX[$M]) }
#$arcstats = 
#$CASMBX = Get-CASMailbox $($MBX[$M])
        $STS = New-Object -TypeName PSObject      
        $STS | Add-Member -MemberType NoteProperty -Name DisplayName -Value $mbxitem.DisplayName
        $STS | Add-Member -MemberType NoteProperty -Name created -Value $mbxitem.whenmailboxcreated
        $STS | Add-Member -MemberType NoteProperty -Name recipienttypedetails -Value $mbxitem.recipienttypedetails
        $STS | Add-Member -MemberType NoteProperty -Name recipienttype -Value $mbxitem.recipienttype
        $STS | Add-Member -MemberType NoteProperty -Name TotalItemSize -Value $mbxstats.TotalItemSize.Value
        $STS | Add-Member -MemberType NoteProperty -Name Items -Value $mbxstats.Itemcount
        $STS | Add-Member -MemberType NoteProperty -Name RECSIZE -Value $($RECitem.Folderandsubfoldersize).Split('(')[0]
        $STS | Add-Member -MemberType NoteProperty -Name Language -Value $itemLNG.Language.DisplayName
        $STS | Add-Member -MemberType NoteProperty -Name Country -Value $itemLNG.Language.name
        $STS | Add-Member -MemberType NoteProperty -Name PrimarySmtpAddress -Value $mbxitem.PrimarySmtpAddress
        If($mbxitem.ArchiveQuota) {$archquo = $($mbxitem.ArchiveQuota).Split('(')[0] } else { $archquo = 'NONE' }
        $STS | Add-Member -MemberType NoteProperty -Name ArchiveQuota -Value $archquo
        $STS | Add-Member -MemberType NoteProperty -Name ArchiveStatus -Value $mbxitem.ArchiveStatus
        $STS | Add-Member -MemberType NoteProperty -Name ArchiveSize -Value $mbxitem.ArchiveStatus
        $STS | Add-Member -MemberType NoteProperty -Name AutoExpandingArchiveEnabled -Value $mbxitem.AutoExpandingArchiveEnabled
        $STS | Add-Member -MemberType NoteProperty -Name ExChangeguid -Value $mbxitem.ExChangeguid.Guid
        $STS | Add-Member -MemberType NoteProperty -Name ExternalDirectoryObjectId -Value $mbxitem.ExternalDirectoryObjectId
        $STS | Add-Member -MemberType NoteProperty -Name Guid -Value $mbxitem.Guid.Guid
        $STS | Add-Member -MemberType NoteProperty -Name ArchiveGuid -Value $mbxitem.ArchiveGuid.Guid
        $STS | Add-Member -MemberType NoteProperty -Name WindowsEmailAddress -Value $mbxitem.WindowsEmailAddress
        $STS | Add-Member -MemberType NoteProperty -Name DistinguishedName -Value $mbxitem.DistinguishedName
        $STS | Add-Member -MemberType NoteProperty -Name LegacyExchangeDN -Value $mbxitem.LegacyExchangeDN
        If($mbxitem.MaxSendSize) { $MxSndSz = $($mbxitem.MaxSendSize).Split('(')[0] } else { $MxSndSz = 'NONE' }
        $STS | Add-Member -MemberType NoteProperty -Name MaxSendSize -Value $MxSndSz
        If($mbxitem.MaxReceiveSize) { $MxRecSz = $($mbxitem.MaxReceiveSize).Split('(')[0] } else { $MxRecSz = 'NONE' }
        $STS | Add-Member -MemberType NoteProperty -Name MaxReceiveSize -Value $MxRecSz
$DATA += $STS }
$DATA | Export-csv $path -NoTypeInformation
$DATA | ft