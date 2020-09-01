# create NEW shared remotemailbox
# create user in AD and run below

enable-remotemailbox user@domain.com -shared -remoteroutingaddress alias@tenant.mail.onmicrosoft.com

# below trigers faster provisioning (+AAD sync)
$ExchangeGuid = [guid]::NewGuid()
set-remotemailbox user@domain.com -ExchangeGuid $ExchangeGuid


# below is for normal remotemailboxes as a reference only
enable-remotemailbox user@domain.com -archive

$Archiveguid = [guid]::NewGuid()
set-remotemailbox user@domain.com -ArchiveGuid $Archiveguid