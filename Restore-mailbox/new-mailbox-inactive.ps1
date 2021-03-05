
$user = "affected@user.com"

$InactiveMailbox = Get-Mailbox -Identity $user -InactiveMailboxOnly

$param = @{ InactiveMailbox = $InactiveMailbox.DistinguishedName
                       Name = $InactiveMailbox.Name
                  FirstName = "FirstName"
                   LastName = "LastName"
                DisplayName = $InactiveMailbox.DisplayName
  MicrosoftOnlineServicesID = $InactiveMailbox.MicrosoftOnlineServicesID
                   Password = (ConvertTo-SecureString -String 'P@ssW0rd' -AsPlainText -Force)
   ResetPasswordOnNextLogon = $false }

                New-Mailbox @param

########## reference #######################################################################################################
# https://docs.microsoft.com/en-us/microsoft-365/compliance/recover-an-inactive-mailbox
# https://docs.microsoft.com/en-us/exchange/troubleshoot/administration/reconnect-inactive-or-soft-deleted-mailboxes-to-ad
############################################################################################################################