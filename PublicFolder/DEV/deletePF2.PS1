# Version 1
foreach ($X in (Get-Mailbox -PublicFolder).Exchangeguid.GUID) { Remove-Mailbox -PublicFolder -Identity $X -force -confirm:$false } 
foreach ($X in (Get-Mailbox -PublicFolder -SoftDeletedMailbox).Exchangeguid.GUID) { Remove-Mailbox -PublicFolder -Identity $X -PermanentlyDelete -force -confirm:$false } 

# Version 2
icm -Session $session -ScriptBlock { Get-Mailbox -PublicFolder | Remove-Mailbox -PublicFolder -force -confirm:$false }
icm -Session $session -ScriptBlock { foreach ($X in (Get-Mailbox -PublicFolder -SoftDeletedMailbox).Exchangeguid.GUID) { Remove-Mailbox -PublicFolder -Identity $X -PermanentlyDelete -force -confirm:$false } }

# Version 3
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