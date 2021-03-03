$String = "JoniS"
   $Mbx = get-mailbox -SoftDeletedMailbox
     $M = $Mbx.Where({$_.userprincipalname -match $String})
   $PWD = (ConvertTo-SecureString -String 'Pa$$word1' -AsPlainText -Force)
 $Param = @{ Password = $PWD
          DisplayName = $M.DisplayName
    SoftDeletedObject = $M.userprincipalname
        WindowsLiveID = $M.WindowsEmailAddress }
Undo-SoftDeletedMailbox @Param
