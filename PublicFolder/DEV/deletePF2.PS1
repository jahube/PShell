# Version 0

$HMBX = $(Get-OrganizationConfig).RootPublicFolderMailbox.HierarchyMailboxGuid ;
$Softd = Get-Mailbox -PublicFolder -SoftDeletedMailbox ;
[System.Collections.ArrayList]$Softdel= $Softd.Exchangeguid.GUID
for ($P = 0; $P -lt $Softdel.count; $P++) { Remove-Mailbox -PublicFolder -Identity $Softdel[$P] -PermanentlyDelete:$true -force -Confirm:$false }

$PFMBX = Get-Mailbox -PublicFolder
$SEC = $PFMBX | Where-object {$_.ExchangeGuid -ne $HMBX} ;
[System.Collections.ArrayList]$PFMSec= $SEC.Exchangeguid.GUID
for ($P = 0; $P -lt $PFMSec.count; $P++) { Remove-Mailbox -PublicFolder -Identity $PFMSec[$P] -force -Confirm:$false }
for ($P = 0; $P -lt $PFMSec.count; $P++) { Remove-Mailbox -PublicFolder -Identity $PFMSec[$P] -PermanentlyDelete:$true -force -Confirm:$false }

$PRIM = $PFMBX | Where-object {$_.ExchangeGuid -eq $HMBX} ;
[System.Collections.ArrayList]$PFMPrim= $PRIM.Exchangeguid.GUID
for ($P = 0; $P -lt $PFMPrim.count; $P++) { Remove-Mailbox -PublicFolder -Identity $PFMPrim[$P] -force -Confirm:$false }
for ($P = 0; $P -lt $PFMPrim.count; $P++) { Remove-Mailbox -PublicFolder -Identity $PFMPrim[$P] -PermanentlyDelete:$true -force -Confirm:$false }

# Version 1
$HMBX = $(Get-OrganizationConfig).RootPublicFolderMailbox.HierarchyMailboxGuid ;
$Softd = Get-Mailbox -PublicFolder -SoftDeletedMailbox ;
$PFMBX = Get-Mailbox -PublicFolder ;
$SEC = $PFMBX | Where-object {$_.ExchangeGuid -ne $HMBX} ;
$PRIM = $PFMBX | Where-object {$_.ExchangeGuid -eq $HMBX} ;
[System.Collections.ArrayList]$PFMSec= $SEC.Exchangeguid.GUID
[System.Collections.ArrayList]$PFMPrim= $PRIM.Exchangeguid.GUID
[System.Collections.ArrayList]$Softdel= $Softd.Exchangeguid.GUID
for ($P = 0; $P -lt $Softdel.count; $P++) { Remove-Mailbox -PublicFolder -Identity $Softdel[$P] -PermanentlyDelete:$true -force -Confirm:$false }
for ($P = 0; $P -lt $PFMSec.count; $P++) { Remove-Mailbox -PublicFolder -Identity $PFMSec[$P] -force -Confirm:$false }
for ($P = 0; $P -lt $PFMSec.count; $P++) { Remove-Mailbox -PublicFolder -Identity $PFMSec[$P] -PermanentlyDelete:$true -force -Confirm:$false }
for ($P = 0; $P -lt $PFMPrim.count; $P++) { Remove-Mailbox -PublicFolder -Identity $PFMPrim[$P] -force -Confirm:$false }
for ($P = 0; $P -lt $PFMPrim.count; $P++) { Remove-Mailbox -PublicFolder -Identity $PFMPrim[$P] -PermanentlyDelete:$true -force -Confirm:$false }


# Version 2
foreach ($X in (Get-Mailbox -PublicFolder).Exchangeguid.GUID) { Remove-Mailbox -PublicFolder -Identity $X -force -confirm:$false } 
foreach ($X in (Get-Mailbox -PublicFolder -SoftDeletedMailbox).Exchangeguid.GUID) { Remove-Mailbox -PublicFolder -Identity $X -PermanentlyDelete -force -confirm:$false } 

# Version 3
icm -Session $session -ScriptBlock { Get-Mailbox -PublicFolder | Remove-Mailbox -PublicFolder -force -confirm:$false }
icm -Session $session -ScriptBlock { foreach ($X in (Get-Mailbox -PublicFolder -SoftDeletedMailbox).Exchangeguid.GUID) { Remove-Mailbox -PublicFolder -Identity $X -PermanentlyDelete -force -confirm:$false } }

# Version 4
try {​​​​​​​ Remove-Mailbox -PublicFolder -Identity (Get-Mailbox -PublicFolder)[-1].Exchangeguid.GUID -Force -Confirm:$false }​​​​​​​ catch {​​​​​​​
try {​​​​​​​ Remove-Mailbox -PublicFolder -Identity (Get-Mailbox -PublicFolder)[-1].Samaccountname -Force -Confirm:$false }​​​​​​​ catch {​​​​​​​
try {​​​​​​​ Remove-Mailbox -PublicFolder -Identity (Get-Mailbox -PublicFolder)[-1].GUID.GUID -Force -Confirm:$false }​​​​​​​ catch {​​​​​​​$Error[0] | FL * }​​​​​​​}​​​​​​​}​​​​​​​

try {​​​​​​​ Remove-Mailbox -PublicFolder -Identity (Get-Mailbox -PublicFolder -SoftDeletedMailbox)[-1].Exchangeguid.GUID -Force -PermanentlyDelete -Confirm:$false }​​​​​​​ catch {​​​​​​​
try {​​​​​​​ Remove-Mailbox -PublicFolder -Identity (Get-Mailbox -PublicFolder -SoftDeletedMailbox)[-1].Samaccountname -Force -PermanentlyDelete -Confirm:$false }​​​​​​​ catch {​​​​​​​
try {​​​​​​​ Remove-Mailbox -PublicFolder -Identity (Get-Mailbox -PublicFolder -SoftDeletedMailbox)[-1].GUID.GUID -Force -PermanentlyDelete -Confirm:$false }​​​​​​​ catch {​​​​​​​$Error[0] | FL * }​​​​​​​}​​​​​​​}​​​​​​​

# Version 5
$HMBX = $(Get-OrganizationConfig).RootPublicFolderMailbox.HierarchyMailboxGuid ;
$PFMSD = Get-Mailbox -PublicFolder -SoftDeletedMailbox ;
$PFMBX = Get-Mailbox -PublicFolder ;
$SEC = $PFMBX | Where-object {$_.ExchangeGuid -ne $HMBX} ;
$PRIM = $PFMBX | Where-object {$_.ExchangeGuid -eq $HMBX} ;
$PFMBXs = @($SEC + $PRIM)
[System.Collections.ArrayList]$PFMSecs= $SEC.Exchangeguid.GUID
$command = @'
Param($P)
for ($P = 0; $P -lt $SEC.count; $P++) { Remove-Mailbox -PublicFolder -Identity $SEC[$P] -force -Confirm:$false }
'@
######################
$session = Get-PSSession -InstanceId (Get-OrganizationConfig).RunspaceId.Guid
$myscriptblock = [scriptblock]::Create("$command")
Invoke-Command -Session $session -ScriptBlock $myscriptblock -ArgumentList $PFMSecs

(Get-PSSession | ? {($_.configurationname -eq "microsoft.exchange") -and ($_.Runspace.ConnectionInfo.ConnectionUri.Host -eq "outlook.office365.com")}).Runspace.SessionStateProxy.LanguageMode