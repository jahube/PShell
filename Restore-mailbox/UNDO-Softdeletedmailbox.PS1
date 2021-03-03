$String = "JohnDoe"
   $Mbx = get-mailbox -SoftDeletedMailbox
     $M = $Mbx.Where({$_.userprincipalname -match $String -or $_.displayname -match $String })
   $PWD = (ConvertTo-SecureString -String 'Pa$$word1' -AsPlainText -Force)
 $Param = @{ Name = $M.Name
         Password = $PWD
      DisplayName = $M.DisplayName
SoftDeletedObject = $M.userprincipalname
    WindowsLiveID = $M.WindowsEmailAddress }
       Undo-SoftDeletedMailbox @Param
