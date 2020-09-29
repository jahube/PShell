$path = "C:\temp"
IF (!(Test-Path $path)) { Mkdir $path }

$mbx = Get-MailboxImportRequest |  Select Mailbox, RequestGuid, Status
$mbx.Mailbox
foreach ($m in $mbx){
$Stats = Get-MailboxImportRequestStatistics $m.RequestGuid -IncludeReport -DiagnosticInfo "showtimeslots,verbose"
$filename = $path + '\' + $m.RequestGuid + '_' + $m.mailbox + '.xml'
$Stats | Export-Clixml -Path $filename }

# DIAG examples

$mbx.Mailbox
IF ($Stats.report.failures) {
$Stats.report.failures | group failuretype
$Stats.report.failures[-1]
} else { Write-Host "No Failures found" -F cyan}

$Stats | ft DataCon*,Bad*,Status*,Message,Missing*
$Stats | ft BytesTransferred*,Status*,Message,Missing*,Items*
$Stats | ft Total*

# alternative

$path = "C:\temp"

$m = Get-MailboxImportRequest | where {$_.Mailbox -contains "ALIAS" } | Select Mailbox, RequestGuid, Status
$m = Get-MailboxImportRequest | Select Mailbox, RequestGuid, Status
$m | % { Get-MailboxImportRequestStatistics $_.RequestGuid -IncludeReport -DiagnosticInfo "showtimeslots,verbose" | Export-Clixml "$path\$($_.RequestGuid).xml" }

# enter filepath
$r = import-clixml "c:\temp\Filename.xml"

#prompt for file path if empty
IF(!($r)) { $P = read-host -Prompt "Enter Path [c:\Temp\FILENAME.XML]"; $r = import-clixml $P}

IF ($Stats.report.failures) {
$r.report.failures | group failuretype
$r.report.failures[-1]
} else { Write-Host "No Failures found" -F cyan}

