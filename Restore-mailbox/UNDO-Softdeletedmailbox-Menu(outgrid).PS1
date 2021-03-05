   $Mbx = get-mailbox -SoftDeletedMailbox | where {($_.ExternaldirectoryObjectId -ne "") -and ($_.ExternaldirectoryObjectId -ne $null) }
     $M = $Mbx | select Name,displayname,userprincipalname,primarysmtpaddress,WindowsEmailAddress,MicrosoftOnlineServicesID | Out-GridView -PassThru

   $PWD = (ConvertTo-SecureString -String 'Pa$$word1' -AsPlainText -Force)

If ($M.MicrosoftOnlineServicesID -ne "") { $WEA = $M.MicrosoftOnlineServicesID }
  ElseIf ($M.WindowsEmailAddress -ne "") { $WEA = $M.WindowsEmailAddress }
                                    Else { $WEA = $M.primarysmtpaddress }
 $Param = @{ Name = $M.Name
         Password = $PWD
      DisplayName = $M.DisplayName
SoftDeletedObject = $M.userprincipalname
    WindowsLiveID = $WEA }
       Undo-SoftDeletedMailbox @Param
