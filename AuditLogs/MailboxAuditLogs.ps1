start-transcript

$path = "C:\mailboxlogs.xml"
$user = "affected user address"

Search-MailboxAuditLog -Identity $user -ShowDetails -StartDate (get-date).AddDays(-90) -EndDate (get-date) | Export-Clixml $path

get-mailbox $user | select AuditEnabled
get-mailbox $user | select -expandproperty auditadmin
get-mailbox $user | select -expandproperty auditdelegate
get-mailbox $user | select -expandproperty auditowner

Stop-transcript