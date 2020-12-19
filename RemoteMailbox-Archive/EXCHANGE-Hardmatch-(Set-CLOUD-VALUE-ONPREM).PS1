#SET MailboxGUID - Byte array converted value from cloud
----------------------------------------------------------
[guid]$MailboxGuid = "CLOUD Exchange GUID HERE"
Set-ADUser $mbx.DistinguishedName -Replace @{msExchMailboxGuid=$MailboxGuid.ToByteArray()}


#SET Archive GUID - Byte array converted value from cloud
----------------------------------------------------------
[guid]$Archiveguid = "CLOUD ARCHIVE GUID VALUE HERE"
Set-ADUser $mbx.DistinguishedName -Replace @{msExchArchiveGUID=$Archiveguid.ToByteArray()}
----------------------------------------------------------

clear disabledArchive GUID
Set-ADUser $mbx.DistinguishedName -clear msExchDisabledArchiveGUID

set disabled archive guid *before enabling (usually not necessary just for reference)
[guid]$DisabledArchiveguid = "DISABLED ARCHIVE GUID HERE"
Set-ADUser $mbx.DistinguishedName -Replace @{msExchDisabledArchiveGUID=$DisabledArchiveguid.ToByteArray()}
