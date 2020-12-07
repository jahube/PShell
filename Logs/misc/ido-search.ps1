$val="email address to check the conflict for" 
Get-AzureADUser |?{$_.ProxyAddress -match "$val" -or $_.Mail -match "$val"} |fl 
Get-AzureADContact |?{$_.ProxyAddress -match "$val" -or $_.Mail -match "$val"} |fl 
Get-AzureADGroup |?{$_.ProxyAddress -match "$val" -or $_.Mail -match "$val"} |fl

#Begin  
$time = Get-Date -Format yyyyMMdd_hhmmss  
$path=[Environment]::GetFolderPath("Desktop")  
$filename="dupcheck_$time.txt"  
$val="$val"  
$FormatEnumerationLimit =-1  
Start-transcript $path\$filename  
Get-Msoluser -all | Where-Object {$_.UserPrincipalName -match "$val" -or $_.ProxyAddresses -match "$val"} | fl   
Get-Msoluser -returndeletedusers -all | Where-Object {$_.UserPrincipalName -match "$val" -or $_.ProxyAddresses -match "$val"} | fl   
Get-MsolContact -all | Where-Object {$_.UserPrincipalName -match "$val"} | fl   
Get-MsolGroup  -all | Where-Object {$_.EmailAddresses -match "$val"  -or $_.ProxyAddresses -match "$val"} | fl 
Get-DistributionGroup -ResultSize unlimited | Where-Object {$_.EmailAddresses -match "$val"} | fl   
Get-DynamicDistributionGroup -ResultSize unlimited | Where-Object {$_.EmailAddresses -match "$val"} | fl   
Get-UnifiedGroup -ResultSize unlimited | Where-Object {$_.EmailAddresses -match "$val"} | fl   
Get-Group -ResultSize unlimited | Where-Object {$_.WindowsEmailAddresses -match "$val"} | fl   
Get-Recipient -ResultSize unlimited | Where-Object {$_.EmailAddresses -match "$val" -or $_.WindowsLiveID -match "$val"} | fl  
Get-MailContact -ResultSize unlimited | Where-Object {$_.EmailAddresses -match "$val"} | fl   
Get-MailUser -ResultSize unlimited | Where-Object {$_.UserPrincipalName -match "$val" -or $_.WindowsLiveID -match "$val" -or $_.EmailAddresses -match "$val"} | fl  
Get-MailUser -SoftDeletedMailUser -ResultSize unlimited | Where-Object {$_.UserPrincipalName -match "$val" -or $_.WindowsLiveID -match "$val" -or $_.EmailAddresses -match "$val"} | fl   
Get-User -ResultSize unlimited | Where-Object {$_.EmailAddresses -match "$val"} | fl   
Get-Mailbox -ResultSize unlimited | Where-Object {$_.EmailAddresses -match "$val" -or $_.WindowsLiveID -match "$val" -or $_.LegacyExchangeDN -match "$val"} | fl   
Get-Mailbox -Softdeleted -ResultSize unlimited | Where-Object {$_.EmailAddresses -match "$val" -or $_.WindowsLiveID -match "$val" -or $_.LegacyExchangeDN -match "$val"} | fl   
Get-Mailbox -InactiveMailboxOnly -ResultSize unlimited | Where-Object {$_.EmailAddresses -match "$val" -or $_.WindowsLiveID -match "$val" -or $_.LegacyExchangeDN -match "$val"} | fl   
Get-Mailbox -PublicFolder -ResultSize unlimited | Where-Object {$_.EmailAddresses -match "$val" -or $_.WindowsLiveID -match "$val" -or $_.LegacyExchangeDN -match "$val"} | fl   
Get-Mailbox -PublicFolder -Softdeleted -ResultSize unlimited | Where-Object {$_.EmailAddresses -match "$val" -or $_.WindowsLiveID -match "$val" -or $_.LegacyExchangeDN -match "$val"} | fl   
Get-Mailbox -PublicFolder -InactiveMailboxOnly -ResultSize unlimited | Where-Object {$_.EmailAddresses -match "$val" -or $_.WindowsLiveID -match "$val" -or $_.LegacyExchangeDN -match "$val"} | fl
Get-Mailbox -GroupMailbox -ResultSize unlimited | Where-Object {$_.EmailAddresses -match "$val" -or $_.WindowsLiveID -match "$val" -or $_.LegacyExchangeDN -match "$val"} | fl   
Get-Mailbox -GroupMailbox -Softdeleted -ResultSize unlimited | Where-Object {$_.EmailAddresses -match "$val" -or $_.WindowsLiveID -match "$val" -or $_.LegacyExchangeDN -match "$val"} | fl   
Get-Mailbox -GroupMailbox -InactiveMailboxOnly -ResultSize unlimited | Where-Object {$_.EmailAddresses -match "$val" -or $_.WindowsLiveID -match "$val" -or $_.LegacyExchangeDN -match "$val"} | fl   
Get-MailPublicFolder -ResultSize unlimited | Where-Object {$_.EmailAddresses -match "$val"} | fl   
Get-Sitemailbox -ResultSize unlimited | Where-Object {$_.EmailAddresses -match "$val"} | fl   
Stop-transcript  
#End

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


$Proxies = Get-MsolUser -UserPrincipalName <UPN> | select proxyaddresses -ExpandProperty ProxyAddresses 
ForEach ($Proxy in $Proxies){ 
    $ProxyF = $proxy.toLower().trimstart("smtp:") 
    Write-host "Searching Proxy: "$ProxyF 
    $Users = Get-MsolUser -all | Where-Object {$_.ProxyAddresses -match "$ProxyF"} 
    $Users.UserPrincipalName 
} 
