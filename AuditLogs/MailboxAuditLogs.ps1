# EXO PS: connection commands reference
# connect
$ADMIN = "admin @ domain"                                    # modify Admin UPN ("login email")
$path = "C:\mailboxlogs.xml"                                 # modify Logs path
$user = "affected @ user"                                    # modify affected user UPN

start-transcript

install-module exchangeonlinemanagement                      # only first time
connect-exchangeonline -userprincipalname $ADMIN             # connect #1
Add-RoleGroupMember "Organization Management" -Member $ADMIN # permissions
connect-exchangeonline -userprincipalname $ADMIN             # reconnnect to reflect permissions - IMPORTANT

Search-MailboxAuditLog -Identity $user -ShowDetails -StartDate (get-date).AddDays(-90) -EndDate (get-date) | Export-Clixml $path

get-mailbox $user | select AuditEnabled
get-mailbox $user | select -expandproperty auditadmin
get-mailbox $user | select -expandproperty auditdelegate
get-mailbox $user | select -expandproperty auditowner

Stop-transcript