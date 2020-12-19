Get-ADUser remoteuserxx -Properties * | fl *arch
get-aduser test2 -Properties *
$mbx = get-aduser test2 -Properties *
$mbx.msExchArchiveGUID = [guid]$mbx.msExchArchiveGUID
$m = $mbx.msExchArchiveGUID
[guid]$m
[guid]$mbx.msExchArchiveGUID
$val = [guid]$m
$mbx.msExchArchiveGUID = [guid]$mbx.msExchArchiveGUID
$val
$r = $val.ToByteArray()
[guid]$r
[guid]$guid = "4a0ed62f-6875-4f7b-a151-1c434c0dcdb1"
$byte = $guid.ToByteArray()
[guid]$byte
[guid]$guid.ToByteArray()
$mbx | ft *guid*,*mail*
[guid]$mbx.msExchArchiveGUID
$mbx = get-aduser USERNAME -Properties *
# $mbx = get-aduser -Filter 'userprincipalname -like "USERNAME*"' -Properties *
#converted GUIDs
[guid]$mbx.msExchMailboxGuid #converted Mailbox GUID
[guid]$mbx.msExchArchiveGUID  #converted Archive GUID
[guid]$mbx.msExchDisabledArchiveGUID  #converted Previousarchive GUID
#recipienttype values
$mbx.msExchRecipientDisplayType
$mbx.msExchRecipientTypeDetails
$mbx.msExchRemoteRecipientType #check REMOTE recipienttype
# check values
if($mbx.msExchMailboxGuid) { write-host "Mailbox GUID $([guid]$mbx.msExchMailboxGuid)" -F green } else { write-host "NO Mailbox GUID" -F yellow }
if($mbx.msExchArchiveGUID) { write-host "archiveGUID $([guid]$mbx.msExchArchiveGUID)" -F green } else { write-host "no archive guid" -F cyan }
if($mbx.msExchDisabledArchiveGUID) { write-host "DISABLED archiveGUID $([guid]$mbx.msExchDisabledArchiveGUID)" -F cyan } else { write-host "no disabled archive guid" -F cyan }
if($mbx.msExchRemoteRecipientType) {write-host "REMOTE Recipienttype $($mbx.msExchRemoteRecipientType)" -F green } else { write-host "NO REMOTE Recipienttype" -F yellow }
if($mbx.msExchRecipientTypeDetails -eq '1') {write-host "LOCAL mailbox RecipientTypeDetails: $($mbx.msExchRecipientTypeDetails) - GUID: $([guid]$mbx.msExchMailboxGuid)" -F green }
#other details
$mbx.SamAccountName
$mbx.sAMAccountType
$mbx.mailNickname
$mbx.DistinguishedName
$mbx.PrimaryGroup
$mbx.proxyAddresses
$mbx.mail
$mbx.whenChanged.ToString()
$mbx.whenCreated.ToString()
$mbx.ObjectGUID
$mbx.ObjectClass
$empty = [guid]::empty
$empty.ToByteArray()
Set-ADUser $mbx.DistinguishedName -Replace @{msExchArchiveGUID=$empty.ToByteArray()}
Set-ADUser $mbx.DistinguishedName -Replace @{msExchArchiveGUID=$([guid]::empty).ToByteArray()}
Set-ADUser $mbx.DistinguishedName -Replace @{msExchDisabledArchiveGUID=$([guid]::empty).ToByteArray()}
Set-ADUser $mbx.DistinguishedName -Replace @{msExchDisabledArchiveGUID=$mbx.msExchDisabledArchiveGUID}
$mbx = get-aduser test2 -Properties *
[guid]$mbx.msExchDisabledArchiveGUID  #converted Previousarchive GUID
$guid = "4a0ed62f-6875-4f7b-a151-1c434c0dcdb1"
Set-ADUser $mbx.DistinguishedName -Replace @{msExchDisabledArchiveGUID=$guid.ToByteArray()}
Set-ADUser $mbx.DistinguishedName -Replace @{msExchDisabledArchiveGUID=$([guid]::empty).ToByteArray()}


####Set-ADUser $mbx.DistinguishedName -Replace @{msExchDisabledArchiveGUID=$([guid]::empty).ToByteArray()}
#### Set-ADUser $mbx.DistinguishedName -Replace @{msExchMailboxGuid=$([guid]::empty).ToByteArray()}
#### Set-ADUser $mbx.DistinguishedName -Replace @{msExchArchiveGUID=$([guid]::empty).ToByteArray()}