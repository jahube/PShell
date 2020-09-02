$search = Get-CalendarDiagnosticLog $user.mail -StartDate 8/25/2019 -EndDate 8/31/2019 | select CleanGlobalObjectId | Get-Unique -AsString).count'
$search | export-csv -path "C:\temp\FILENAME.CSV"

# OR

Get-CalendarDiagnosticLog -Identity "user" -Subject "subject" > "C:\temp\FILENAME.CSV"

# Then

Get-CalendarDiagnosticAnalysis -LogLocation "C:\temp\FILENAME.CSV" -DetailLevel Advanced -OutputAs CSV > "C:\temp\log2.csv"
 