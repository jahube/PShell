$ts = Get-Date -Format yyyyMMdd_hhmmss; 
$FormatEnumerationLimit = -1
$Path=[Environment]::GetFolderPath("Desktop")
$clouduser1 = "USER@CONTOSO.COM"
Get-mailbox $clouduser1 | fl > $Path\$ts.mbx1_o365.txt
Get-User $clouduser1 |fl > $Path\$ts.user1_o365.txt
Get-MsolUser -UserPrincipalName $clouduser1 | fl > $Path\$ts.msoluser1_o365.txt
(Get-MsolUser -UserPrincipalName $clouduser1).licenses.servicestatus > $Path\$ts.msoluser_ServiceStatus_o365.txt 
(Get-Msoluser -userprincipalname $clouduser1).errors.errorDetail.objectErrors.errorRecord.errorDescription >  $Path\$ts.msolUserErr.txt
Get-Mailbox $clouduser1 -SoftDeletedMailbox | fl > $Path\$ts. Target_Mailbox_SoftDeleted.txt
Get-Mailbox -InactiveMailboxOnly | fl Name,DistinguishedName,ExchangeGuid,PrimarySmtpAddress > $Path\$ts. Target_Mailbox_Inactive.txt
Get-mailbox $clouduser1 -softdeletedmailbox | fl guid > C:\source_guid.txt
Stop-transcript  
#End