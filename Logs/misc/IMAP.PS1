
# Open in Powershell ISE {Ctrl+N} and edit the marked below
$Mailbox = "<AffectedMailbox>"

### Eg.: $Mailbox = "User@contoso.com"
$Batch = "<BatchName>"

### Eg.: $Batch = "User1 Contoso com"
$MigrationEndpoint = "<MigrationEndpoint>"

### Eg.: $MigrationEndpoint = "IMAP Endpoint mail.contoso.com"
$Path = $ENV:UserProfile\Desktop\Temp$Path = "C:\Temp"

## choose any of the 2 Examples above and modify
Get-MigrationBatch $Batch -IncludeReport -DiagnosticInfo "showtimeslots, showtimeline, verbose" | Export-Clixml $Path\MigrationBatch_$Batch.xml

Get-MigrationUser $Mailbox | Export-Clixml $Path\MigrationUser_$Mailbox.xml

Get-MigrationUserStatistics $Mailbox -IncludeSkippedItems -IncludeReport -DiagnosticInfo "showtimeslots, showtimeline, verbose" | Export-Clixml $Path\MigrationUserStatistics_$Mailbox.xml

Get-SyncRequest $Mailbox | Export-Clixml C:\Temp\MSSupport\SyncRequest_$Mailbox.xml

Get-SyncRequestStatistics $Mailbox -IncludeReport -DiagnosticInfo "showtimeslots, showtimeline, verbose" | Export-Clixml $Path\SyncRequestStatistics_$Mailbox.xml

# IMAP_Optional
Get-MigrationEndpoint $MigrationEndpoint -DiagnosticInfo Verbose | Export-Clixml $Path\MigrationEndpoint_$MigrationEndpoint.xml

Get-MigrationConfig | Export-Clixml $Path\MigrationConfig.xml

Get-MailboxFolderStatistics $Mailbox -IncludeOldestAndNewestItems -IncludeAnalysis -FolderScope nonipmroot | Export-Clixml $Path\MailboxFolderStatistics_$Mailbox.xml