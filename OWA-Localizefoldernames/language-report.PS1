$path = "C:\results.csv"
# NEW - MBX stats all users
$mbxs = Get-Mailbox -ResultSize Unlimited 
[System.Collections.ArrayList]$MBX = $mbxs.userprincipalname ; $DATA = @()
for ($M = 0; $M -lt $MBX.count; $M++) { $S =" [MBX] ($($M+1)/$count)  [Time]"
$A = "collecting stats [Mailbox Count] ($($M+1)/$count) [Mailbox] $($MBX[$M])"
Write-Progress -Activity $A -Status $S -PercentComplete (($M/$count)*100) -SecondsRemaining ($count-$M) ;
$mbxitem = icm { get-mailbox $($MBX[$M]) }
$itemLNG = icm { Get-MailboxRegionalConfiguration $($MBX[$M]) }
        $STS = New-Object -TypeName PSObject      
        $STS | Add-Member -MemberType NoteProperty -Name DisplayName -Value $mbxitem.DisplayName
        $STS | Add-Member -MemberType NoteProperty -Name created -Value $mbxitem.whenmailboxcreated
        $STS | Add-Member -MemberType NoteProperty -Name recipienttypedetails -Value $mbxitem.recipienttypedetails
        $STS | Add-Member -MemberType NoteProperty -Name recipienttype -Value $mbxitem.recipienttype
        $STS | Add-Member -MemberType NoteProperty -Name Language -Value $itemLNG.Language.DisplayName
        $STS | Add-Member -MemberType NoteProperty -Name Country -Value $itemLNG.Language.name
        $STS | Add-Member -MemberType NoteProperty -Name DateFormat -Value $itemLNG.Language.DateFormat
        $STS | Add-Member -MemberType NoteProperty -Name DateFormat-Value $itemLNG.TimeFormat
        $STS | Add-Member -MemberType NoteProperty -Name TimeZone -Value $itemLNG.Language.TimeZone
        $STS | Add-Member -MemberType NoteProperty -Name PrimarySmtpAddress -Value $mbxitem.PrimarySmtpAddress
        $STS | Add-Member -MemberType NoteProperty -Name AutoExpandingArchiveEnabled -Value $mbxitem.AutoExpandingArchiveEnabled
        $STS | Add-Member -MemberType NoteProperty -Name ExChangeguid -Value $mbxitem.ExChangeguid.Guid
        $STS | Add-Member -MemberType NoteProperty -Name ExternalDirectoryObjectId -Value $mbxitem.ExternalDirectoryObjectId
        $STS | Add-Member -MemberType NoteProperty -Name Guid -Value $mbxitem.Guid.Guid
$DATA += $STS }
$DATA | Export-csv $path -NoTypeInformation
$DATA | group Language,TimeZone