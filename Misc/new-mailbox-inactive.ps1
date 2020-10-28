



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



###############

Install-Module MSOnline

Connect-MsolService
 

Get-MsolUser -UserPrincipalName "affected@user.com" | Remove-MsolUser
Get-MsolUser -UserPrincipalName "affected@user.com" -ReturnDeletedUsers | Remove-MsolUser -RemoveFromRecycleBin

Get-MsolUser -ObjectId dd5fadd7-f80b-4912-93c2-d36eb3fdb564 | Remove-MsolUser
Get-MsolUser -ObjectId dd5fadd7-f80b-4912-93c2-d36eb3fdb564 -ReturnDeletedUsers | Remove-MsolUser -RemoveFromRecycleBin