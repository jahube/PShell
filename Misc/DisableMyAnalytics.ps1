$MBX = get-mailbox -ResultSize unlimited
$Mailusers = Get-MailUser -ResultSize unlimited
$privacymode = "Opt-Out"
$OptOutUsers =  @()
$OptInUsers = @()
$failed = @()

Foreach ($M in $mbx.userprincipalname) {
If((Get-UserAnalyticsConfig -Identity $M).PrivacyMode -eq 'Opt-Out') { 
write-Host "User $($M) already opted out" -F green } else {
Try { Set-UserAnalyticsConfig -Identity $M -PrivacyMode $privacymode -EA 'stop' ; 
Write-host "[Mailbox] $M set to $($privacymode)" -F green } catch { 
Write-host $error[0].Exception.Message -F Yellow ; $failed+= $M  }
If((Get-UserAnalyticsConfig -Identity $M).PrivacyMode -eq 'Opt-Out') { 
Write-host "[Mailbox] $M set to $($privacymode) confirmed" -F cyan ; 
$OptOutUsers += $M } else { $OptInUsers += $M }}}

# Experimental: mailuser (probably better to filter MSOL users having MyAnalytics enabled)
Foreach ($M in $Mailusers.userprincipalname) {
If((Get-UserAnalyticsConfig -Identity $M).PrivacyMode -eq 'Opt-Out') { 
write-Host "User $($M) already opted out" -F green } else {
Try { Set-UserAnalyticsConfig -Identity $M -PrivacyMode $privacymode -EA 'stop' ; 
Write-host "[Mailbox] $M set to $($privacymode)" -F green } catch { 
Write-host $error[0].Exception.Message -F Yellow ; $failed+= $M  }
If((Get-UserAnalyticsConfig -Identity $M).PrivacyMode -eq 'Opt-Out') { 
Write-host "[Mailbox] $M set to $($privacymode) confirmed" -F cyan ; 
$OptOutUsers += $M } else { $OptInUsers += $M }}}

get-mailuser localhost*