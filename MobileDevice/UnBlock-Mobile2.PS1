# modify user
$user = "affected@user.com"

# LIST
Get-MobileDeviceStatistics -mailbox $user |ft *son,*ate,*fri*,*lied,*us,*imei*,*type,*os

############ short ##################################################################

foreach ($id in @(Get-mobiledevice -Mailbox $user).DeviceID) { 
Set-CASMailbox -identity $user -ActiveSyncAllowedDeviceIDs @{add=$id} }
Set-CASMailbox -identity $user -ActiveSyncBlockedDeviceIDs $Null

#####################################################################################

     $MD = Get-mobiledevice -Mailbox $user
$blocked = @($MD | where { ($_.DeviceAccessState -eq "Quarantined") -or ($_.DeviceAccessState -eq "Blocked") }).DeviceID | sort-object -unique
foreach ($id in $blocked) {Try {Set-CASMailbox -identity $user -ActiveSyncBlockedDeviceIDs @{remove=$id} } catch {}
foreach ($id in $blocked) {Try {Set-CASMailbox -identity $user -ActiveSyncAllowedDeviceIDs @{add=$id}    } catch {}
foreach ($id in $blocked) {Try {Set-CASMailbox -identity $user -ActiveSyncBlockedDeviceIDs @{remove=$id} } catch {}
Set-CASMailbox -identity $user -ActiveSyncBlockedDeviceIDs $Null }

#####################################################################################

# read devices
$MD = Get-mobiledevice -Mailbox $user

# remove Blocked
Set-CASMailbox -identity $user -ActiveSyncBlockedDeviceIDs $Null

# try to add all user devices
foreach ($M in $MD) { $id = $M.DeviceID;
                Try { Set-CASMailbox -identity $user -ActiveSyncAllowedDeviceIDs @{add=$id} }
              catch { Write-Host $Error[0] }
                Try { Set-CASMailbox -identity $user -ActiveSyncBlockedDeviceIDs @{remove=$id} }
              catch { Write-Host $Error[0] }
}
##### END ###########################################################################

#####################################################################################
# LONG
#####################################################################################

# read devices
$MD = Get-mobiledevice -Mailbox $user

$CSMBX = Get-CASMailbox -identity $user
$allowed = @($MD | where { $_.DeviceAccessState -eq "Allowed" }).DeviceID
$blocked = @($MD | where { ($_.DeviceAccessState -eq "Quarantined") -or ($_.DeviceAccessState -eq "Blocked") }).DeviceID
$allowlist = @($CSMBX.ActiveSyncAllowedDeviceIDs)
$blocklist = @($CSMBX.ActiveSyncBlockedDeviceIDs)

# remove Blocked
Set-CASMailbox -identity $user -ActiveSyncBlockedDeviceIDs $Null

foreach ($id in $blocked) {
                      Try { Set-CASMailbox -identity $user -ActiveSyncAllowedDeviceIDs @{add=$id} }
                    catch { Write-Host $Error[0] }
                      Try { Set-CASMailbox -identity $user -ActiveSyncBlockedDeviceIDs @{remove=$id} }
                    catch { Write-Host $Error[0] } }

# remove Blocked
Set-CASMailbox -identity $user -ActiveSyncBlockedDeviceIDs $Null

# remove existing (if needed)
# Set-CASMailbox -identity $user -ActiveSyncAllowedDeviceIDs $Null



#       $Param = @{ identity = $user
# ActiveSyncAllowedDeviceIDs = @{add=$id} }
#               Set-CASMailbox $Param


get-deviceconditionalaccesspolicy
get-deviceconditionalaccessrule
get-activesyncorganizationsettings
get-devicepolicy
get-devicetenantpolicy
get-activesyncdevice