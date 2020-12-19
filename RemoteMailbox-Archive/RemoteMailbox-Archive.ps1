
# GET
$mbx = get-aduser "USERNAME" -Properties *

# below converts the Byte arrays in cloud readable format, its quick and helpful
[guid]$mbx.msExchMailboxGuid #converted Mailbox GUID
[guid]$mbx.msExchArchiveGUID  #converted Archive GUID
[guid]$mbx.msExchDisabledArchiveGUID  #converted Previousarchive GUID

$mbx.msExchRecipientDisplayType
$mbx.msExchRecipientTypeDetails
$mbx.msExchRemoteRecipientType #check REMOTE recipienttype


#SET Recipienttypes- Byte array converted value from cloud
----------------------------------------------------------
$mbx = get-aduser "USERNAME" -Properties *
Set-ADUser $mbx.DistinguishedName -Replace @{msExchRemoteRecipientType='3'}
Set-ADUser $mbx.DistinguishedName -Replace @{msExchRecipientDisplayType='-2147483642'}
Set-ADUser $mbx.DistinguishedName -Replace @{msExchRecipientTypeDetails='2147483648'}

#SET MailboxGUID - Byte array converted value from cloud
----------------------------------------------------------
[guid]$MailboxGuid = "CLOUD Exchange GUID HERE"
Set-ADUser $mbx.DistinguishedName -Replace @{msExchMailboxGuid=$MailboxGuid.ToByteArray()}


#SET Archive GUID - Byte array converted value from cloud
----------------------------------------------------------
[guid]$Archiveguid = "CLOUD ARCHIVE GUID VALUE HERE"
Set-ADUser $mbx.DistinguishedName -Replace @{msExchArchiveGUID=$Archiveguid.ToByteArray()}
----------------------------------------------------------

set disabled archive guid *before enabling (usually not necessary just for reference)
[guid]$DisabledArchiveguid = "DISABLED ARCHIVE GUID HERE"
Set-ADUser $mbx.DistinguishedName -Replace @{msExchDisabledArchiveGUID=$DisabledArchiveguid.ToByteArray()}

clear disabledArchive GUID
Set-ADUser $mbx.DistinguishedName -clear msExchDisabledArchiveGUID

----------------------------------------------------------

# create NEW shared remotemailbox
# create user in AD and run below

enable-remotemailbox user@domain.com -shared -remoteroutingaddress alias@tenant.mail.onmicrosoft.com

enable-remotemailbox user@domain.com -archive


FOR PROVISIONING (generate NEW GUID for NEW shared mailboxes or nonexisting deprovisioned Cloud MBX) 
*** DONT use for existing data DATALOSS ***
//////////////////////////////////////////////////////////////////////
# provision new GUID (+AAD sync)
//////////////////////////////////////////////////////////////////////
# *DATALOSS* *DATALOSS* *DATALOSS* !!! clearing OTHER value should only be used if you know what you are doing for a specific purpose  *DATALOSS
### Set-ADUser $mbx.DistinguishedName -clear PROPERTY
# Set-ADUser $mbx.DistinguishedName -Replace @{msExchMailboxGuid=$([guid]::NewGuid()}
# set-remotemailbox user@domain.com -ExchangeGuid $([guid]::NewGuid())
# set-remotemailbox user@domain.com -ArchiveGuid $([guid]::NewGuid())

# *DATALOSS* *DATALOSS* *DATALOSS* !!! clearing OTHER value should only be used if you know what you are doing for a specific purpose  *DATALOSS
//////////////////////////////////////////////////////////////////////
