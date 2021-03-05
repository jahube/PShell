  # $Mbx = get-mailbox -SoftDeletedMailbox | where {($_.ExternaldirectoryObjectId -eq "") -or ($_.ExternaldirectoryObjectId -eq $null) }
$Mbx = get-mailbox -InactiveMailboxOnly | where {($_.ExternaldirectoryObjectId -eq "") -or ($_.ExternaldirectoryObjectId -eq $null) }
$M = $Mbx | select Name,displayname,userprincipalname,primarysmtpaddress,MicrosoftOnlineServicesID,WindowsEmailAddress | Out-GridView -PassThru -title "Select Mailbox to Re-Connect"
Write-host $M -F cyan

If ($M.MicrosoftOnlineServicesID -ne "") { $WEA = $M.MicrosoftOnlineServicesID ; write-host "MSOL-SID used for Windowslive [$WEA]" -F yellow }
  ElseIf ($M.WindowsEmailAddress -ne "") { $WEA = $M.WindowsEmailAddress ; write-host "WindowsEmailAddress used for Windowslive [$WEA]" -F yellow }
                                    Else { $WEA = $M.primarysmtpaddress ; write-host "PrimarySMTP used for Windowslive [$WEA]" -F yellow}
$UPN = $M.userprincipalname
$splitname = $UPN.Split('@')[0].Replace('.', ' ')
# output = First Last
$splitfirst = $splitname.Split(' ')[0] # FIRST.last@domain.com ; 
$splitfirst = $splitfirst.substring(0,1).toupper() + $splitfirst.substring(1).tolower()
$splitlast = $splitname.Split(' ')[-1] # first.LAST@domain.com 
$splitlast = $splitlast.substring(0,1).toupper() + $splitlast.substring(1).tolower()
$splitname = "$($splitfirst + ' ' + $splitlast)"

$param = @{ InactiveMailbox = $M.DistinguishedName
                       Name = $M.Name
                  FirstName = $splitfirst
                   LastName = $splitlast
                DisplayName = $M.DisplayName
  MicrosoftOnlineServicesID = $WEA
                   Password = (ConvertTo-SecureString -String 'P@ssW0rd' -AsPlainText -Force)
   ResetPasswordOnNextLogon = $false }

                New-Mailbox @param

########## reference #######################################################################################################
# https://docs.microsoft.com/en-us/microsoft-365/compliance/recover-an-inactive-mailbox
# https://docs.microsoft.com/en-us/exchange/troubleshoot/administration/reconnect-inactive-or-soft-deleted-mailboxes-to-ad
############################################################################################################################