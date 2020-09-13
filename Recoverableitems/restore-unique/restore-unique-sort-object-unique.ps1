##############
#   search   #
##############
$user = 'affected@user.com'

$search = Get-RecoverableItems $user -FilterStartTime (get-date).AddDays(-180) -FilterEndTime (get-date).Addyears(2)

# Calendar Items only
# $search = Get-RecoverableItems $user -FilterItemType IPM.Appointment -FilterStartTime (get-date).AddDays(-180) -FilterEndTime (get-date).Addyears(2) 

# Messages only
# $search = Get-RecoverableItems $user -FilterItemType IPM.Note -FilterStartTime (get-date).AddDays(-180) -FilterEndTime (get-date).Addyears(2) 

$unique = $search | Sort-Object subject -unique
$search | Sort-Object subject | Select subject,EntryID
$unique | Select subject,EntryID

Write-host "`nFound $($search.count)" -F yellow
Write-host "`nUnique $($unique.count)" -F green

##############
#  restoring #
##############
$done = @()
$failed = @()
Foreach ($n in $unique) {
try { Restore-RecoverableItems -Identity $user -EntryID "$($n.entryid)" -EA 'stop' ;
$done += $n
} catch { 
Write-Host "$($n.subject) failed to restore" -F yellow ;
$failed += $n
        }  
}
##############
Write-host "`nrestored $($done.count)" -F green
Write-host "`nFailed $($failed.count)" -F yellow

# reference https://powershell.org/forums/topic/get-unique-items-from-an-array/