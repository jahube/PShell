# install-module exchangeonlinemanagement
# connect-exchangeonline -UserPrincipalName ADMIN

$user = "affected@user.com"
$path = "C:\Temp"

$logs = Get-CalendarDiagnosticLog $user -Subject "Full Name1 Jr.'s Birthday" -ExactMatch ; $logs

# Specific
$logs = Get-CalendarDiagnosticLog $user -Subject "office hours" ; $logs

# range -14 => last 14 days
$logs = Get-CalendarDiagnosticLog $user -StartDate (get-date).AddDays(-14) -EndDate (get-date) ; $logs.count

$IDs = $logs | select CleanGlobalObjectId | Get-Unique -AsString
$results = foreach ($id in $IDs) {​ Get-CalendarDiagnosticObjects -Identity $user -MeetingId $id }​
# export as one file
$results| Export-csv $path\logs.csv -NoTypeInformation
# export separately as <MEETINGID>.CSV
$results = foreach ($id in $IDs) {​ Get-CalendarDiagnosticObjects -Identity $user -MeetingId $id | Export-csv $path\$($id)_log.csv -NoTypeInformation }​
    
    
  
  

