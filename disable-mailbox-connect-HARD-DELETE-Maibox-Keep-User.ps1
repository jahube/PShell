$admin = ""

#Admin + PS check
Try { Set-ExecutionPolicy RemoteSigned -Force -EA stop } catch { Write-host "restart as Admin / check Permissions" -F Yellow }
if ($($PSVersionTable.PSVersion.ToString()) -lt "5") { Write-Host "Powerhell $($PSVersionTable.PSVersion.ToString()) doesn't support Install-module" -F yellow}

#admin
if (!($admin)) {$admin = read-host -Prompt "Enter Global Admin [Admin@domain.com]" }
#credential
if (!($cred)) {$cred = Get-Credential $admin}

#Trust Powershell Gallery
if (!(get-PackageProvider nuget)) { write-host "Adding NUGet Package Provider" -F green; Install-PackageProvider -Name NuGet -Force -Scope CurrentUser -Confirm:$false }
if ($((Get-PSRepository -Name "PSGallery").InstallationPolicy) -ne 'trusted') { write-host "Adding PSGallery Trust" -F green;Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted }

#MSOL Check / Login - Else TLS + install
if(Get-MsolDomain -ErrorAction SilentlyContinue) { Write-host 'MSOL connected' -F green} else { try { Connect-MsolService -Credential $cred } catch { 
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
try {Install-Module MSOnline -Scope CurrentUser -Confirm:$false -EA stop } catch { Write-host $Error[0].Exception.Message -F yellow }
try { Connect-MsolService -Credential $cred -EA stop } catch { Write-host $Error[0].Exception.Message -F yellow }}}

# check EXO V2 Installed + Connect Exo
if (!(get-module ExchangeOnlineManagement)) { Try { Install-Module ExchangeOnlineManagement -Scope CurrentUser -Confirm:$false -EA stop } catch { Write-host $Error[0].Exception.Message -F yellow}}
Try{ Connect-ExchangeOnline -Credential $cred -EA stop } catch { Connect-ExchangeOnline -UserPrincipalName $admin }

#AFFECTED USERS
$users = "" # "user1","user2"
if (!($users)) {$users = read-host -Prompt "enter affected user [USER@domain.com]" }

#SIZE
Try { Get-MailboxStatistics -Identity $user -IncludeSoftDeletedRecipients| fl Itemcount,Totalitemsize } catch { Write-host $Error[0]}

# MSOL USER INFO
Foreach ($user in $users) {

Try { $u = Get-MsolUser -userprincipalname $user -ErrorAction SilentlyContinue } catch { Write-Host $Error[0].Exception.Message -F green }
Try { $d = Get-MsolUser -userprincipalname $user -ReturnDeletedUsers -ErrorAction SilentlyContinue } catch { Write-Host $Error[0].Exception.Message -F green }
if($d -eq $null -and $u -eq $null)  { Write-Host "MSOLUser $user Harddeleted" -F cyan }
if($d -ne $null -and $u -eq $null)  { Write-Host "MSOLUser $user SOFTdeleted" -F yellow }
if($d -eq $null -and $u -ne $null)  { Write-Host "Active MSOLUser $user existing" -F green }
if($d -ne $null -and $u -ne $null)  { Write-Host "MSOLUser $user active + Softdeleted Duplicate(s)" -F yellow }
 }
#end


# LICENCE Check + Removal
Foreach ($user in $users) {
$lic = (Get-MsolUser -userprincipalname $user).Licenses
$exolic = $lic | Where {$_.ServiceStatus.serviceplan.servicename -match "exchange"}
$disable = $lic.ServiceStatus.serviceplan.servicename | Where {$_ -match "exchange"}
If ($exolic) { write-host "user $user has a LICENCE - please disable to remove mailbox in next steps" -F yellow ; write-host $disable }
if(!($exolic)) {Write-host "$user has NO EXO license" -F cyan}
#$ServiceDisable = New-MsolLicenseOptions -AccountSkuId $exolic.AccountSkuId -DisabledPlans $disable
#Set-MsolUserLicense -UserPrincipalName $user -LicenseOptions $ServiceDisable
if ($exolic) { Try { Set-MsolUserLicense -UserPrincipalName $user -RemoveLicenses $exolic.AccountSkuId } catch { Write-Host $Error[0].Exception -F yellow }}
}


#check Mailboxes exist
Foreach ($user in $users) {
Try { $mbx = Get-Mailbox $user -ErrorAction SilentlyContinue } catch { Write-Host $Error[0].Exception.Message -F green }
if($mbx -ne $null) { Write-Host "User $user has active Mailbox" -F green }
if($mbx -eq $null) {
Try { $softdel = Get-Mailbox $user -SoftDeletedMailbox -ErrorAction SilentlyContinue } catch { Write-Host $Error[0].Exception.Message -F green }
if($softdel -ne $null) { Write-Host "User $user has a SoftDeletedMailbox" -F yellow }
if($softdel -eq $null -and $mbx -eq $null) { Write-Host "User $user has NO Mailbox" -F Cyan }
}}
#end

# Get-OrganizationConfig | fl *hold*
# Get-Mailbox $user | fl *hold*
# Set-Mailbox $user -ExcludeFromOrgHolds $true
# Get-Mailbox $user|fl compl*,delay*,inplace*

# Holds are only updated when license is added for removal
# otherwise Validation Error prevents hold from being removed

# Remove Mailboxes - don't forget to remove license
Foreach ($user in $users) {
Try { Set-Mailbox -Identity $user -RetentionHoldEnabled $false -RemoveDelayHoldApplied -RemoveDelayReleaseHoldApplied -CF:$false -EA stop } catch { Write-Host "$($Error[0].Exception.Message)" -F green }
Try { Set-Mailbox -Identity $user -RetentionHoldEnabled $false -RemoveDelayReleaseHoldApplied -CF:$false -EA stop } catch { Write-Host "$($Error[0].Exception.Message)" -F green }
Try { Set-Mailbox -Identity $user -Type Shared -CF:$false -EA stop } catch { Write-Host "$($Error[0].Exception.Message)" -F green }
Try { Disable-Mailbox $user -Archive -CF:$false -EA stop } catch { Write-Host "$($Error[0].Exception.Message)" -F green }
Try { Disable-Mailbox $user -Archive -PermanentlyDisable -CF:$false -EA stop } catch { Write-Host "$($Error[0].Exception.Message)" -F green }
Try { Disable-Mailbox $user -CF:$false -EA stop } catch { Write-Host "$($Error[0].Exception.Message)" -F green }
Try { Disable-Mailbox $user -PermanentlyDisable -CF:$false -EA stop } catch { Write-Host "$($Error[0].Exception.Message)" -F green }
Try { Set-User $user -PermanentlyClearPreviousMailboxInfo -CF:$false -EA stop } catch { Write-Host "$($Error[0].Exception.Message)" -F green }
}
#end
