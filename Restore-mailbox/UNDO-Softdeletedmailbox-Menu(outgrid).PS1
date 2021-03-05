   $Mbx = get-mailbox -SoftDeletedMailbox | where {($_.ExternaldirectoryObjectId -ne "") -and ($_.ExternaldirectoryObjectId -ne $null) }
     $M = $Mbx | select Name,displayname,userprincipalname,primarysmtpaddress,WindowsEmailAddress,MicrosoftOnlineServicesID | Out-GridView -PassThru

   $PWD = (ConvertTo-SecureString -String 'Pa$$word1' -AsPlainText -Force)

If ($M.MicrosoftOnlineServicesID -ne "") { $WEA = $M.MicrosoftOnlineServicesID ; write-host "MSOL-SID used for Windowslive [$WEA]" -F yellow }
  ElseIf ($M.WindowsEmailAddress -ne "") { $WEA = $M.WindowsEmailAddress ; write-host "WindowsEmailAddress used for Windowslive [$WEA]" -F yellow }
                                    Else { $WEA = $M.primarysmtpaddress ; write-host "PrimarySMTP used for Windowslive [$WEA]" -F yellow}
 $Param = @{ Name = $M.Name
         Password = $PWD
      DisplayName = $M.DisplayName
SoftDeletedObject = $M.userprincipalname
    WindowsLiveID = $WEA }
       Undo-SoftDeletedMailbox @Param
