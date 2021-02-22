$MBX = get-mailbox -ResultSize unlimited

$privacymode = "Opt-Out" # "Opt-In"

$OptOutUsers =  @() ; $OptInUsers = @() ; $failed = @()

# disable for all Users // Set-MyAnalyticsFeatureConfig

Foreach ($M in $mbx.userprincipalname) {
If((Get-MyAnalyticsFeatureConfig -Identity $M).PrivacyMode -eq $privacymode) { 
write-Host "User $($M) already $privacymode" -F green } else {
Try { Set-MyAnalyticsFeatureConfig -Identity $M -PrivacyMode $privacymode -EA 'stop' ; 
Write-host "[Mailbox] $M set to $privacymode" -F green } catch { 
Write-host $error[0].Exception.Message -F Yellow ; $failed+= $M  }
If((Get-MyAnalyticsFeatureConfig -Identity $M).PrivacyMode -eq $privacymode) { 
Write-host "[Mailbox] $M set to $privacymode confirmed" -F cyan ; 
$OptOutUsers += $M } else { $OptInUsers += $M }}}

# disable on Exchange OWA APP level

$insights = get-app -organizationapp | where { $_.Displayname -match 'insights'}
$insights | fl displayname,description,defaultstateforuser,enabled,appid
$insights | % { set-app -organizationapp $_.Appid -Enabled $false }
$insights | % { set-app -organizationapp $_.Appid -DefaultStateForUser 'Disabled' }

