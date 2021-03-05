   $Mbx = get-mailbox -SoftDeletedMailbox
     $M = $Mbx | select Name,displayname,userprincipalname,primarysmtpaddress,WindowsEmailAddress | Out-GridView -PassThru
   $PWD = (ConvertTo-SecureString -String 'Pa$$word1' -AsPlainText -Force)
 $Param = @{ Name = $M.Name
         Password = $PWD
      DisplayName = $M.DisplayName
SoftDeletedObject = $M.userprincipalname
    WindowsLiveID = $M.WindowsEmailAddress }
       Undo-SoftDeletedMailbox @Param
