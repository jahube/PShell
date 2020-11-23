#experimental session options
$option = New-PSSessionOption -IdleTimeout "4300000" -MaximumRedirection 5 -Culture "DE-DE" -OpenTimeout "4300000" -MaxConnectionRetryCount "1000" -OperationTimeout "4300000" -SkipRevocationCheck -MaximumReceivedObjectSize 500MB -MaximumReceivedDataSizePerCommand 50MB
# connect EXO PS
Connect-ExchangeOnline -UserPrincipalName admin@edu.dnsabr.com -PSSessionOption $option
# connect Skype PS
$sfbSession = New-CsOnlineSession -Credential $credential -SessionOption $option  ; Import-PSSession $sfbSession -AllowClobber
# get-pssession | Remove-PSSession  #otherwise close session and reconnect

#############################################################################
#############################################################################
# OPTION 2 AUTO PARSE Skype Queues
#############################################################################
# reconnect Skype
#############################################################################
$option = New-PSSessionOption -IdleTimeout "4300000" -MaximumRedirection 5 -Culture "DE-DE" -OpenTimeout "4300000" -MaxConnectionRetryCount "1000" -OperationTimeout "4300000" -SkipRevocationCheck -MaximumReceivedObjectSize 500MB -MaximumReceivedDataSizePerCommand 50MB
get-pssession | Remove-PSSession ; $sfbSession = New-CsOnlineSession -Credential $credential -SessionOption $option  ; Import-PSSession $sfbSession -AllowClobber
Connect-ExchangeOnline -UserPrincipalName admin@DOMAIN.com -PSSessionOption $option
#############################################################################
###############     Auto Parse Calling Queues      ##########################
#############################################################################
$queuelist = get-CsCallQueue
$collected=@() ; $mbx =@()
  foreach ($queue in $queuelist)
    {
    #users
    if ($queue.users.guid) { # IF START
        foreach ($GUID in $queue.users.guid) { # Foreach Start
        $mbx = @(get-mailbox $GUID)
        $qcq2 = New-Object -TypeName PSObject
        $qcq2 | Add-Member -MemberType NoteProperty -Name CallingQueue -Value $queue.name   
        $qcq2 | Add-Member -MemberType NoteProperty -Name UserAlias -Value $mbx.alias
        $qcq2 | Add-Member -MemberType NoteProperty -Name userprincipalname -Value $mbx.userprincipalname
        $qcq2 | Add-Member -MemberType NoteProperty -Name primarysmtpaddress -Value $mbx.primarysmtpaddress
        $qcq2 | Add-Member -MemberType NoteProperty -Name UserGUID -Value $GUID
        $qcq2 | Add-Member -MemberType NoteProperty -Name EXOGUID -Value $mbx.exchangeguid
        $qcq2 | Add-Member -MemberType NoteProperty -Name Queueguid -Value $queue.identity
        $qcq2 | Add-Member -MemberType NoteProperty -Name MemberType -Value user
        $collected += $qcq2                   } # Foreach End
                           } # IF END
    #DL
 <#     if ($queue.DistributionLists.guid) { # IF START
        foreach ($GUID in $queue.users.guid) { # Foreach Start
        $mbx = get-mailbox $GUID
        $qcq = New-Object -TypeName PSObject
        $qcq | Add-Member -MemberType NoteProperty -Name CallingQueue -Value $queue.name    
        $qcq | Add-Member -MemberType NoteProperty -Name UserAlias -Value $mbx.alias
        $qcq | Add-Member -MemberType NoteProperty -Name userprincipalname -Value $mbx.userprincipalname
        $qcq | Add-Member -MemberType NoteProperty -Name primarysmtpaddress -Value $mbx.primarysmtpaddress
        $qcq | Add-Member -MemberType NoteProperty -Name UserGUID -Value $GUID
        $qcq | Add-Member -MemberType NoteProperty -Name EXOGUID -Value $mbx.exchangeguid
        $qcq | Add-Member -MemberType NoteProperty -Name Queueguid -Value $queue.identity
        $qcq | Add-Member -MemberType NoteProperty -Name MemberType -Value $queue.identity
        $collected += $qcq                   } # Foreach End
                           } # IF END       #>
    }
$collected | ft
$collected | export-csv c:\queue2.csv -NoTypeInformation
#############################################################################
############     Mass Add  CallingQueue from Above     ######################
############   stamp callingqueue on customattibute12   #####################
#############################################################################
$queue = ($CSVqueue | group Callingqueue).name
$cnt1 = $queue.count ; $A = "[Adding Custom Tag for Queue:]" ; $B = "[Adding Custom Tag for Mailbox:]"
for ($X = 0; $X -lt $cnt1; $X++) { $qname = $queue[$X] ; $S = " - [ $qname ]"
Write-Progress -Activity $A -Status $S -PercentComplete $(($X/$cnt1)*100) -SecondsRemaining $($cnt1-$X) ;
$Qusers = ($CSVqueue).Where({$_.Callingqueue -eq $qname }) ; $cnt2 = $Qusers.count  ;
for ($U = 0; $U -lt $cnt2; $U++) { $S2 = " - [ $($Qusers[$U].primarysmtpaddress) ]"
Write-Progress -Id 1 -Activity $B -Status $S2 -PercentComplete $(($U/$cnt2)*100) -SecondsRemaining $($cnt2-$U) ;
set-mailbox -Identity $($Qusers[$U].userguid) -CustomAttribute12 $qname  } }