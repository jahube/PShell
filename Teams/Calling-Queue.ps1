Import-Csv blabla.csv | % { Set-Mailbox $_.UserPrincipalName -CustomAttribute10 "bla" -CustomAttribute8 "blah" }
get-mailbox
$mbx = get-mailbox -ResultSize unlimited
#############################
Install-Module MicrosoftTeams
$credential = Get-Credential
#Connect to Microsoft Teams
Connect-MicrosoftTeams -Credential $credential
##############################################
Get-CsCallQueue
##############################################
$option = New-PSSessionOption -IdleTimeout "4300000" -MaximumRedirection 5 -Culture "DE-DE" -OpenTimeout "4300000" -MaxConnectionRetryCount "1000" -OperationTimeout "4300000" -SkipRevocationCheck -MaximumReceivedObjectSize 500MB -MaximumReceivedDataSizePerCommand 50MB
$sfbSession = New-CsOnlineSession -Credential $credential -SessionOption $option
Import-PSSession $sfbSession
#get-pssession | Remove-PSSession
##################################
New-CsCallQueue -Name "HelpDesk1" -UseDefaultMusicOnHold $true
New-CsCallQueue -Name "HelpDesk2" -UseDefaultMusicOnHold $true
New-CsCallQueue -Name "HelpDesk3" -UseDefaultMusicOnHold $true
New-CsCallQueue -Name "HelpDesk4" -UseDefaultMusicOnHold $true
New-CsCallQueue -Name "HelpDesk5" -UseDefaultMusicOnHold $true
New-CsCallQueue -Name "HelpDesk6" -UseDefaultMusicOnHold $true

$mbx.count
$Skypeuser = Get-CsOnlineUser -ResultSize unlimited
$Skypeuser.count
######################################
$q1 = $Skypeuser[0..19] ; $q1.count
$q2 = $Skypeuser[20..39] ; $q2.count
$q3 = $Skypeuser[40..59] ; $q3.count
$q4 = $Skypeuser[60..79] ; $q4.count
$q5 = $Skypeuser[80..99] ; $q5.count
$q6 = $Skypeuser[100..119] ; $q6.count
######################################
$qc1 = get-CsCallQueue -Name "HelpDesk1" 
$qc2 = get-CsCallQueue -Name "HelpDesk2" 
$qc3 = get-CsCallQueue -Name "HelpDesk3"
$qc4 = get-CsCallQueue -Name "HelpDesk4"
$qc5 = get-CsCallQueue -Name "HelpDesk5"
$qc6 = get-CsCallQueue -Name "HelpDesk6"
[System.Collections.ArrayList]$q1c = $q1.objectid
[System.Collections.ArrayList]$q2c = $q2.objectid
[System.Collections.ArrayList]$q3c = $q3.objectid
[System.Collections.ArrayList]$q4c = $q4.objectid
[System.Collections.ArrayList]$q5c = $q5.objectid
[System.Collections.ArrayList]$q6c = $q6.objectid
Set-CsCallQueue -Identity $qc1.Identity -Users $q1c
Set-CsCallQueue -Identity $qc2.Identity -Users $q2c
Set-CsCallQueue -Identity $qc3.Identity -Users $q3c
Set-CsCallQueue -Identity $qc4.Identity -Users $q4c
Set-CsCallQueue -Identity $qc5.Identity -Users $q5c
Set-CsCallQueue -Identity $qc6.Identity -Users $q6c
for ($qq = 0; $qq -lt $q1.count; $qq++) { Get-Mailbox $mailboxUPN[$F]  } }
for ($qq = 0; $qq -lt $q2.count; $qq++) { Get-Mailbox $mailboxUPN[$F]  } }
for ($qq = 0; $qq -lt $q3.count; $qq++) { Get-Mailbox $mailboxUPN[$F]  } }
for ($qq = 0; $qq -lt $q4.count; $qq++) { Get-Mailbox $mailboxUPN[$F]  } }
for ($qq = 0; $qq -lt $q5.count; $qq++) { Get-Mailbox $mailboxUPN[$F]  } }
$par1 = (get-CsCallQueue)[0].users
$par2 = (get-CsCallQueue)[1].users
$par3 = (get-CsCallQueue)[2].users
$par4 = (get-CsCallQueue)[3].users
$par5 = (get-CsCallQueue)[4].users
$par6 = (get-CsCallQueue)[5].users
$quelist = get-CsCallQueue
  $collected=@()
        $qcq = New-Object -TypeName PSObject
  foreach ($queue in get-CsCallQueue)
    {
        $qcq = New-Object -TypeName PSObject        
        $qcq | Add-Member -MemberType NoteProperty -Name $queue.name -Value $queue.users
        $collected += $qcq 
    }
  $listreport=@()
foreach ($CCs in $collected)
    {
        $qcq = New-Object -TypeName PSObject        
        $qcq | Add-Member -MemberType NoteProperty -Name $queue.name -Value $queue.users
        $collected += $qcq 
    }

 $list =@() ;  foreach($dayit in $dayitems) { $DMScount += $dayit.MsgCount/1 }
        $datum | Add-Member -MemberType NoteProperty -Name $queue.name -Value $queue.users