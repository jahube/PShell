##############
#   search   #
##############
$user = 'admin@edu.dnsabr.com'

$search = Get-RecoverableItems $user -FilterStartTime (get-date).AddDays(-180) -FilterEndTime (get-date).Addyears(2)

$Filter = $search | Sort-Object | Select-Object subject -unique

$search | Sort-Object subject | Select subject,EntryID
$Filter | Select subject,EntryID
Write-host "`nSearch found $($search.count)" -F yellow
Write-host "`nFiltered $($filter.count)" -F green
#################################################################################
#  matching filtered with first entry (adding back entryID from first match [0] #
#################################################################################
# $new = $null
$new = @()

foreach ($F in $filter) {

$unique = ($search | where { $_.subject -eq $f.Subject })[-1]

$new += $unique
}
$new  | Select subject,entryid
Write-host "`nFilter + entryID $($new.count)" -F green
##############
#  restoring #
##############
$done = @()
$failed = @()
Foreach ($n in $new) {
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
