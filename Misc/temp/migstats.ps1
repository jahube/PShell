$r.report.MailboxVerification
$ver = $r.Report.MailboxVerification
$ver | ? {$_.FolderTargetPath-match $folderName} | select FolderTargetPath, @{Name="MissingItemInTargetCount"; Expression={$_.MissingInTargetCount.Count}} , @{Name="ItemCountBeforeMove"; Expression={$_.Source.Count}}, @{Name="ItemCountAfterMove"; Expression={$_.Target.Count}} | ?{$_.ItemCountBeforeMove -gt 0 -or $_.ItemCountAfterMove -gt 0} | ft -a

$MoveRequestStatistics = Import-Clixml C:\temp\MoveRequestStatistics.xml

$MoveRequestStatistics | select * -ExcludeProperty Report, DiagnosticInfo
$MoveRequestStatistics.DiagnosticInfo
$MoveRequestStatistics.Report.ToString()
$MoveRequestStatistics.Report.Failures
$MoveRequestStatistics.Report.InternalFailures
$MoveRequestStatistics.Report.MailboxVerification
$MoveRequestStatistics.Report.BadItems
$MoveRequestStatistics.Report.LargeItems
$MoveRequestStatistics.Report.Connectivity
$MoveRequestStatistics.Report.Entries
$MoveRequestStatistics.Report.DebugEntries
$MoveRequestStatistics.Report.SourceMailboxBeforeMove
$MoveRequestStatistics.Report.TargetMailboxAfterMove
$MoveRequestStatistics.Report.SourceMailUserAfterMove
$MoveRequestStatistics.Report.TargetMailUserBeforeMove
$MoveRequestStatistics.Report.SourceThrottles
$MoveRequestStatistics.Report.TargetThrottles
$MoveRequestStatistics.Report.SessionStatistics
$MoveRequestStatistics.Report.SourceMailboxSize
$MoveRequestStatistics.Report.TargetMailboxSize
$MoveRequestStatistics.Report.SourceArchiveMailboxSize
$MoveRequestStatistics.Report.TargetArchiveMailboxSize
#4. Hints about how to parse logs:
$MoveRequestStatistics.Report.Failures | select FailureType -Unique
$MoveRequestStatistics.Report.Failures | group FailureType | ft -AutoSize Count, Name
$MoveRequestStatistics.Report.Failures | where {$_.FailureSide -like "Target"} | select Timestamp, WorkItem,FailureSide, FailureType, @{n='Message'; e={($_.Message -split "\n")[0]}} | ft -AutoSize
$MoveRequestStatistics.Report.Failures | where {$_.FailureSide -like "Source"} | select Timestamp, WorkItem,FailureSide, FailureType, @{n='Message'; e={($_.Message -split "\n")[0]}} | ft -AutoSize
#5. Hints about how to parse logs if specific failure is found:
### If FailureType is "TimeoutErrorTransientException"
$MoveRequestStatistics.Report.Failures | where {$_.FailureType -like "TimeoutErrorTransientException"} | selectTimestamp, FailureType, FailureSide, Message
$MoveRequestStatistics.Report.Failures | where {$_.FailureType -like "TimeoutErrorTransientException"} | selectTimestamp, FailureType, FailureSide, Message | Export-Csv C:\Temp\MSSupport\TimeoutErrorTransientException1.csv -NoTypeInformation -Force
### If FailureType is "SourceMailboxAlreadyBeingMovedTransientException", you should take a look onhttps://blogs.msdn.microsoft.com/brad_hughes/2016/12/16/source-mailbox-already-being-moved-errors-while-moving-mailboxes/
$firstMailboxLockedError = $MoveRequestStatistics.Report.Failures | where { $_.FailureType -eq 'SourceMailboxAlreadyBeingMovedTransientException' } | Select -First 1
$MoveRequestStatistics.Report.Failures | sort Timestamp -Descending | where { $_.Timestamp -lt $firstMailboxLockedError.Timestamp } | Select -First 1 | fl
### If FailureType is "TargetPrincipalMappingException"
$MoveRequestStatistics.Report.Failures | where {$_.FailureType -like "TargetPrincipalMappingException"} | selectTimestamp, FailureType, Message, @{n="Alias";e={(($_.DataContext -split "Alias: ")[1] -split "`;")[0]}},@{n="DisplayName";e={(($_.DataContext -split "DisplayName: ")[1] -split "`;")[0]}}, @{n="MailboxGuid";e={(($_.DataContext -split "MailboxGuid: ")[1] -split "`;")[0]}}, @{n="SID";e={(($_.DataContext -split "SID: ")[1] -split"`;")[0]}}, @{n="Folder";e={(($_.DataContext -split "Folder: `'")[1] -split "`'`,")[0]}}
$MoveRequestStatistics.Report.Failures | where {$_.FailureType -like "TargetPrincipalMappingException"} | selectTimestamp, FailureType, Message, @{n="Alias";e={(($_.DataContext -split "Alias: ")[1] -split "`;")[0]}},@{n="DisplayName";e={(($_.DataContext -split "DisplayName: ")[1] -split "`;")[0]}}, @{n="MailboxGuid";e={(($_.DataContext -split "MailboxGuid: ")[1] -split "`;")[0]}}, @{n="SID";e={(($_.DataContext -split "SID: ")[1] -split"`;")[0]}}, @{n="Folder";e={(($_.DataContext -split "Folder: `'")[1] -split "`'`,")[0]}} | Export-CsvC:\Temp\MSSupport\TargetPrincipalMappingException.csv -NoTypeInformation -Force
### If FailureType is "SourcePrincipalMappingException"
$MoveRequestStatistics.Report.Failures | where {$_.FailureType -like "SourcePrincipalMappingException"} | selectTimestamp, FailureType, Message, @{n="SID";e={(($_.DataContext -split "SID: ")[1] -split "`;")[0]}}, @{n="Folder";e={(($_.DataContext -split "Folder: `'")[1] -split "`'`,")[0]}}
$MoveRequestStatistics.Report.Failures | where {$_.FailureType -like "SourcePrincipalMappingException"} | selectTimestamp, FailureType, Message, @{n="SID";e={(($_.DataContext -split "SID: ")[1] -split "`;")[0]}}, @{n="Folder";e={(($_.DataContext -split "Folder: `'")[1] -split "`'`,")[0]}} | Export-CsvC:\Temp\MSSupport\SourcePrincipalMappingException.csv -NoTypeInformation -Force