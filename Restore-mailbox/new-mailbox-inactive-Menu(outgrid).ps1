  # $Mbx = get-mailbox -SoftDeletedMailbox | where {($_.ExternaldirectoryObjectId -eq "") -or ($_.ExternaldirectoryObjectId -eq $null) }
$Mbx = get-mailbox -InactiveMailboxOnly
$M = $Mbx | select Name,displayname,userprincipalname,primarysmtpaddress,MicrosoftOnlineServicesID,WindowsEmailAddress | Out-GridView -PassThru -title "Select Mailbox to Re-Connect"
Write-host $M -F cyan
$FirstName = read-host "Enter First Name"
 $LastName = read-host "Enter Last Name"
$param = @{ InactiveMailbox = $InactiveMailbox.DistinguishedName
                       Name = $InactiveMailbox.Name
                  FirstName = $FirstName
                   LastName = $LastName
                DisplayName = $InactiveMailbox.DisplayName
  MicrosoftOnlineServicesID = $InactiveMailbox.MicrosoftOnlineServicesID
                   Password = (ConvertTo-SecureString -String 'P@ssW0rd' -AsPlainText -Force)
   ResetPasswordOnNextLogon = $false }

                New-Mailbox @param

########## reference #######################################################################################################
# https://docs.microsoft.com/en-us/microsoft-365/compliance/recover-an-inactive-mailbox
# https://docs.microsoft.com/en-us/exchange/troubleshoot/administration/reconnect-inactive-or-soft-deleted-mailboxes-to-ad
############################################################################################################################