$path = "C:\results.csv"
$admin = "admin@domain.com"
$cred = get-credential $admin

$option = New-PSSessionOption -IdleTimeout "4300000" -MaximumRedirection 5 -Culture "DE-DE" -OpenTimeout "4300000" -MaxConnectionRetryCount "1000" -OperationTimeout "4300000" -SkipRevocationCheck -MaximumReceivedObjectSize 500MB -MaximumReceivedDataSizePerCommand 50MB -OutBuffer 4

get-pssession | where { $_.state -eq "broken" } | Remove-PSSession

function ExoConnect
{
$session = (get-pssession | where { $_.Availability -eq "Available" })
   IF (!($session) -or (Get-PSSession $session.Id).Availability -ne "Available") {


try ( Connect-ExchangeOnline -credential $cred -PSSessionOption $option } catch { Write-host "too many PS Sessions" get-pssession | where { $_.state -eq "broken" } | Remove-PSSession }

If (!(get-session | where { $_.Availability -ne "busy" })) { Write-host "wait for running Jobs" ; get-job | where { $_.state -eq "running" }| wait-Job
$session = (get-pssession | where { $_.Availability -eq "Available" })[-1] }
}

# NEW - MBX stats all users
# $mbxs = icm { Get-EXOMailbox -ResultSize Unlimited -PropertySets All }
# $Mstats = icm { $mbxs | Get-MailboxStatistics -AsJob }
# $Mstats = icm { $mbxs | Get-EXOMailboxStatistics }

# $time = [system.diagnostics.stopwatch]::startNew()
# $RECitemsrch = icm { $mbx | Get-EXOMailboxFolderStatistics -folderscope recoverableitems } -AsJob
# $time.Elapsed

# $time = [system.diagnostics.stopwatch]::startNew()
# $RECitems = Invoke-Command -Session $session -ArgumentList $mbxs -ScriptBlock { Receive-Job (get-job)[-1] | Get-MailboxStatistics } -AsJob -JobName "Job2"
# $time.Elapsed

$time = [system.diagnostics.stopwatch]::startNew()

$session1 = (get-pssession | where { $_.Availability -eq "Available" })[-1]

$Get_Mailbox = Invoke-Command -Session $session1 -ScriptBlock { Get-Mailbox -ResultSize Unlimited } -AsJob -JobName "Get_Mailbox"


$session2 = (get-pssession | where { $_.Availability -eq "Available" })[-1]

$Get_CASMailbox = Invoke-Command -Session $session2 -ScriptBlock { Get-CASMailbox -ResultSize Unlimited } -AsJob -JobName "Get_CASMailbox"


$session3 = (get-pssession | where { $_.Availability -eq "Available" })[-1]

$MBXStats = Invoke-Command -Session $session3 -ScriptBlock { Get-Mailbox -ResultSize Unlimited | Get-MailboxStatistics } -AsJob -JobName "MBXStats"

get-job | where { $_.state -eq "running" }| wait-Job

get-job | where { $_.state -eq "completed" -or $_.state -eq "running" }
get-pssession

$session1 = (get-pssession | where { $_.Availability -eq "Available" })[-1]
Invoke-Command -Session $session1 -ScriptBlock { Get-Mailbox -ResultSize Unlimited -Archive | Get-MailboxStatistics -Archive } -AsJob -JobName "MBXStats_Archive"
$session2 = (get-pssession | where { $_.Availability -eq "Available" })[-1]
Invoke-Command -Session $session2 -ScriptBlock { Get-Mailbox -ResultSize Unlimited | Get-MailboxFolderStatistics -folderscope recoverableitems } -AsJob -JobName "RECitems"
$session3 = (get-pssession | where { $_.Availability -eq "Available" })[-1]
Invoke-Command -Session $session3 -ScriptBlock { Get-Mailbox -ResultSize Unlimited -Archive | Get-MailboxFolderStatistics -Archive -folderscope recoverableitems } -AsJob -JobName "RECitems_Archive"

get-job | where { $_.state -eq "completed" -or $_.state -eq "running" }
get-pssession

# Stop-Job -id 36
# Remove-Job -id 36
get-job | where { $_.state -eq "running" }| wait-Job

$Job_Get_Mailbox  = Receive-Job (get-job | where { $_.state -eq "completed" -and $_.Name -eq "Get_Mailbox" } )[-1] -Keep
$Job_Get_CASMailbox  = Receive-Job (get-job | where { $_.state -eq "completed" -and $_.Name -eq "Get_CASMailbox" } )[-1] -Keep

$Job_MBXStats  = Receive-Job (get-job | where { $_.state -eq "completed" -and $_.Name -eq "MBXStats" } )[-1] -Keep
$Job_MBXStats_Archive  = Receive-Job (get-job | where { $_.state -eq "completed" -and $_.Name -eq "MBXStats_Archive" } )[-1] -Keep

$Job_RECitems = Receive-Job (get-job | where { $_.state -eq "completed" -and $_.Name -eq "RECitems" } )[-1] -Keep
$Job_RECitems_Archive  = Receive-Job (get-job | where { $_.state -eq "completed" -and $_.Name -eq "RECitems_Archive" } )[-1] -Keep

<#
$Job_Get_Mailbox
$Job_RECitemsArchive   | fl identity,MailboxGuid,OwnerADGuid,mailboxItemCount,TotalDeletedItemSize,DeletedItemCount
$Job_MBXStats_Archive   | fl identity,MailboxGuid,OwnerADGuid,mailboxItemCount,TotalDeletedItemSize,DeletedItemCount
($Job_RECitems | sort-object DeletedItemsInFolder -Descending)[0] | fl identity,Name,ContentMailboxGuid,OwnerADGuid,ItemsInFolderAndSubfolders,FolderAndSubfolderSize,DeletedItemsInFolder,NewestItemReceivedDate
$Job_RECitems | Select Name,foldertype,@{name=”Folderandsubfoldersize (MB)”; expression={[math]::Round( `
($_.Folderandsubfoldersize.ToString().Split(“(“)[1].Split(” “)[0].Replace(“,”,””)/1MB),2)}},Itemsinfolderandsubfolders,oldestitemreceiveddate,NewestItemReceivedDate
$Job_RECitems_Archive  | fl identity,ContentMailboxGuid,OwnerADGuid,mailboxItemCount,TotalDeletedItemSize,DeletedItemCount

$Job_RECitems_Archive.where( { $_.FolderType -eq "RecoverableItemsRoot"} ) | ft identity,ItemsInFolderAndSubfolders,FolderAndSubfolderSize
$Job_RECitems.where( { $_.FolderType -eq "RecoverableItemsRoot"} ) | ft identity,ItemsInFolderAndSubfolders,FolderAndSubfolderSize

$Job_RECitems.where( { $_.FolderType -eq "RecoverableItemsRoot"} )[0] | fl identity,MailboxGuid,OwnerADGuid,mailboxItemCount,TotalDeletedItemSize,DeletedItemCount
$Job_RECitemsArchive[0] | fl identity,MailboxGuid,OwnerADGuid,mailboxItemCount,TotalDeletedItemSize,DeletedItemCount
#>
#####################################################################
# $mbxitem = $mbxs.where({ $_.userprincipalname -eq $($MBX[$M]) })
# $mbxitem | fl * -f convertto-json
# get-exomailbox da2a9552-8fc6-4493-8cac-4b48d0132eb9 -PropertySets All | fl *name*,*guid*
#####################################################################
# $RECitems.where( { $_.FolderType -eq "RecoverableItemsRoot"} )
#####################################################################

<#
$Mbxstats = $Job2
$Mbxstats[0] | fl * -f
get-mailbox da2a9552-8fc6-4493-8cac-4b48d0132eb9 | fl *name*,*guid*,*exter*
$Jobs = get-job
$Jobs | where { $_.HasMoreData -eq $true }
Receive-Job (get-job | where { $_.name -eq "archive" })

$RECitems_root = $Job_RECitems.where({$_.FolderType -eq "RecoverableItemsRoot" })
$RECitems_root_Archive = $Job_RECitems.where({$_.FolderType -eq "RecoverableItemsRoot" })

$ArchiveStats = Receive-Job (get-job | where { $_.name -eq "MBXStats.Archive" })
$ArchiveStats[0] | fl * -f
$RECitems = $RECitemsrch.where( { $_.FolderType -eq "RecoverableItemsRoot"} ) }
$ArchiveStat = $ArchiveStats.where({ $_.OwnerADGuid -eq $mbxitem.guid }) #>

############################################################################

$mbxs = $Job_Get_Mailbox

$CASMbxs = $Job_Get_CASMailbox

$Mbxstats = $Job_MBXStats

$ArchiveStats = $Job_MBXStats_Archive

$RECitems_root = $Job_RECitems.where({$_.FolderType -eq "RecoverableItemsRoot" })

$RECitems_root_Archive = $Job_RECitems_Archive.where({$_.FolderType -eq "RecoverableItemsRoot" })

 ############################################################################
[System.Collections.ArrayList]$MBX = $mbxs.userprincipalname ;
$DATA = @()
$count = $MBX.count
############################################################################
for ($M = 0; $M -lt $count) {

############################################################################
# From Job
$mbxitem = $mbxs.where({ $_.userprincipalname -eq $($MBX[$M]) })[0]
# Legacy per item - slow - for reference
# $mbxitem = icm { get-EXOmailbox $($MBX[$M]) }
############################################################################

############################################################################
# From Job
$CASmbxitem = $CASMbxs.where({ $_.guid -eq $mbxitem.guid })[0] # $($MBX[$M])
# Legacy per item - slow - for reference
# $mbxitem = icm { get-EXOmailbox $($MBX[$M]) }
############################################################################

############################################################################
# From Job
$mbxstat = $Mbxstats.where({ $_.OwnerADGuid -eq $mbxitem.guid })[0]
############################################################################
# Legacy per item - slow - for reference
# $mbxstat = icm { Get-EXOMailboxStatistics $($MBX[$M]) }
############################################################################

############################################################################
# From Job
$ArchiveStat = $ArchiveStats.where({ $_.OwnerADGuid -eq $mbxitem.guid })

############################################################################
# Legacy per item - slow - for reference
# $mbxstat = icm { Get-EXOMailboxStatistics -archive $($MBX[$M]) }
############################################################################

############################################################################
# From Job
$RECitem = $RECitems_root.where({$mbxstat.MailboxGuid -eq $_.ContentMailboxGuid }) | Select Name,foldertype,@{name=”Folderandsubfoldersize (MB)”; expression={[math]::Round( `
($_.Folderandsubfoldersize.ToString().Split(“(“)[1].Split(” “)[0].Replace(“,”,””)/1MB),2)}},Itemsinfolderandsubfolders,oldestitemreceiveddate,NewestItemReceivedDate

############################################################################
#fallback alias-match
If (!($RECitem)) { $RECitem = $RECitems.where({$_.FolderType -eq "RecoverableItemsRoot" -and $mbxitem.Alias -eq $_.Identity.split('\')[0] }) }
############################################################################
# Legacy per item - slow - for reference
# $RECitem = icm { (Get-EXOMailboxFolderStatistics -Identity $($MBX[$M]) -folderscope recoverableitems).where( { $_.FolderType -eq "RecoverableItemsRoot"} ) }
############################################################################

############################################################################
# From Job
$RECitemArchive = $RECitems_root_Archive.where({$mbxstat.MailboxGuid -eq $_.ContentMailboxGuid }) | Select Name,foldertype,@{name=”Folderandsubfoldersize (MB)”; expression={[math]::Round( `
($_.Folderandsubfoldersize.ToString().Split(“(“)[1].Split(” “)[0].Replace(“,”,””)/1MB),2)}},Itemsinfolderandsubfolders,oldestitemreceiveddate,NewestItemReceivedDate
############################################################################
#fallback alias-match
If (!($RECitem)) { $RECitem = $RECitems.where({$_.FolderType -eq "RecoverableItemsRoot" -and $mbxitem.Alias -eq $_.Identity.split('\')[0] }) }
############################################################################
# Legacy per item - slow - for reference
# $RECitem = icm { (Get-EXOMailboxFolderStatistics -archive -Identity $($MBX[$M]) -folderscope recoverableitems).where( { $_.FolderType -eq "RecoverableItemsRoot"} ) }
############################################################################

# remove later **
#$Job_RECitems_Archive | Select Name,foldertype,@{name=”Folderandsubfoldersize (MB)”; expression={[math]::Round( `
#($_.Folderandsubfoldersize.ToString().Split(“(“)[1].Split(” “)[0].Replace(“,”,””)/1MB),2)}},Itemsinfolderandsubfolders,oldestitemreceiveddate,NewestItemReceivedDate

############################################################################
# Language info - Slow - commented out for performance/use
# $itemLNG = icm { Get-MailboxRegionalConfiguration $($MBX[$M]) }
############################################################################
#$CASMBX = Get-CASMailbox $($MBX[$M])
############################################################################

        $STS = New-Object -TypeName PSObject      
        $STS | Add-Member -MemberType NoteProperty -Name DisplayName -Value $mbxitem.DisplayName
        $STS | Add-Member -MemberType NoteProperty -Name PrimarySmtpAddress -Value $mbxitem.PrimarySmtpAddress
        $STS | Add-Member -MemberType NoteProperty -Name ExchangeGUID -Value $mbxitem.ExchangeGUID.Guid
        $STS | Add-Member -MemberType NoteProperty -Name ExternalDirectoryObjectId -Value $mbxitem.ExternalDirectoryObjectId
        $STS | Add-Member -MemberType NoteProperty -Name Guid -Value $mbxitem.Guid.Guid
        $STS | Add-Member -MemberType NoteProperty -Name ArchiveGuid -Value $mbxitem.ArchiveGuid.Guid
        $STS | Add-Member -MemberType NoteProperty -Name WindowsEmailAddress -Value $mbxitem.WindowsEmailAddress

        $STS | Add-Member -MemberType NoteProperty -Name created -Value $mbxitem.whenmailboxcreated
        $STS | Add-Member -MemberType NoteProperty -Name recipienttypedetails -Value $mbxitem.recipienttypedetails
        $STS | Add-Member -MemberType NoteProperty -Name recipienttype -Value $mbxitem.recipienttype
        ############# CASMailbox blocked Protocols #################################
        # pending ***
        ############# Mailbox Statistics ###########################################
        $STS | Add-Member -MemberType NoteProperty -Name TotalItemSize -Value $mbxstat.TotalItemSize.Value
        $STS | Add-Member -MemberType NoteProperty -Name Items -Value $mbxstat.Itemcount
        ############# Archive Statistics ###########################################

        If($ArchiveStat) {$ArchiveSize = $ArchiveStat.TotalItemSize.Value ; $ArchiveCount = $ArchiveStat.Itemcount }
                    else { $ArchiveSize = "0" ; $ArchiveCount = "0" }

        $STS | Add-Member -MemberType NoteProperty -Name ArchiveSize -Value $ArchiveSize
        $STS | Add-Member -MemberType NoteProperty -Name ArchiveCount -Value $ArchiveCount

        ############# Recoverable Items Folder Statistics ##########################
       
        If($RECitem) {$RecSize = $RECitem.”Folderandsubfoldersize (MB)" ; $RecCount = $RECitem.Itemsinfolderandsubfolders }
                else { $RecSize = "0" ; $RecCount = "0" }

        $STS | Add-Member -MemberType NoteProperty -Name RecSize -Value $RecSize
        $STS | Add-Member -MemberType NoteProperty -Name RecCount -Value $RecCount
       
        ############# ARCHIVE Mbx - Recoverable Items Folder Statistics ############
       
        If($RECitemArchive) { $RecSizeArchive = $RECitem.”Folderandsubfoldersize (MB)" ; $RecCountArchive = $RECitem.Itemsinfolderandsubfolders }
                       else { $RecSizeArchive = "0" ; $RecCountArchive = "0" }

        $STS | Add-Member -MemberType NoteProperty -Name RecSizeArchive -Value $RecSizeArchive
        $STS | Add-Member -MemberType NoteProperty -Name RecCountArchive -Value $RecCountArchive

        ############################################################################
   #     $STS | Add-Member -MemberType NoteProperty -Name Language -Value $itemLNG.Language.DisplayName
   #     $STS | Add-Member -MemberType NoteProperty -Name Country -Value $itemLNG.Language.name
   ############################################################################
   
     #   If($mbxitem.ArchiveQuota) {$ArchiveQuota = $($mbxitem.ArchiveQuota).Split('(')[0] } else { $ArchiveQuota = 'NONE' }
    #    $STS | Add-Member -MemberType NoteProperty -Name ArchiveQuota -Value $ArchiveQuota
        $STS | Add-Member -MemberType NoteProperty -Name ArchiveStatus -Value $mbxitem.ArchiveStatus
        $STS | Add-Member -MemberType NoteProperty -Name AutoExpandingArchiveEnabled -Value $mbxitem.AutoExpandingArchiveEnabled
        <#
        $STS | Add-Member -MemberType NoteProperty -Name ArchiveSize -Value $mbxitem.ArchiveStatus
        $STS | Add-Member -MemberType NoteProperty -Name ArchiveSize -Value $mbxitem.ArchiveStatus
        $STS | Add-Member -MemberType NoteProperty -Name ArchiveSize -Value $mbxitem.ArchiveStatus
        $STS | Add-Member -MemberType NoteProperty -Name ArchiveSize -Value $mbxitem.ArchiveStatus
       #>

        ############################################################################
        $STS | Add-Member -MemberType NoteProperty -Name DistinguishedName -Value $mbxitem.DistinguishedName
        $STS | Add-Member -MemberType NoteProperty -Name LegacyExchangeDN -Value $mbxitem.LegacyExchangeDN
        If($mbxitem.MaxSendSize) { $MxSndSz = $($mbxitem.MaxSendSize).Split('(')[0] } else { $MxSndSz = 'NONE' }
        $STS | Add-Member -MemberType NoteProperty -Name MaxSendSize -Value $MxSndSz
        If($mbxitem.MaxReceiveSize) { $MxRecSz = $($mbxitem.MaxReceiveSize).Split('(')[0] } else { $MxRecSz = 'NONE' }
        $STS | Add-Member -MemberType NoteProperty -Name MaxReceiveSize -Value $MxRecSz
$DATA += $STS
$M++
$S =" [MBX] ($M/$count)  [Time]"
$A = "collecting stats [Mailbox Count] ($M/$count) [Mailbox] $($MBX[$M])"

Write-Progress -Activity $A -Status $S -PercentComplete (($M/$count)*100) -SecondsRemaining ($count-$M)
}
$DATA | Export-csv $path -NoTypeInformation
$DATA | ft