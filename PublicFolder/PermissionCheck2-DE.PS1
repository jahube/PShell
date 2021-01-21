# << ============= Variables ===================================== >> #

$FolderScope = '\'

$Path = "C:\FolderData.CSV"

$AnonymousPerm = "CreateItems"

$DefaultPerm = "Author"

$Anonymous = 'Anonym'

$Default = 'Standard'

# << ============== Script Start ================================= >> #

$PFs = get-publicfolder $FolderScope –Recurse -resultsize unlimited

$count = $PFs.count ; $err = @() ; $Folderdata = @() ; $missingowner = @() ; $FalseAno = @() ; $FalseDef = @()

      For ($P = 0; $P -lt $PFs.count; $P++) { 

       $Folder = $PFs[$P].identity.ToString()

Write-Progress -Activity "Checking permissions  " -Id 2 -ParentId 1 -Status "[current Folder] $Folder" -PercentComplete (($P/$count)*100) -SecondsRemaining $($count-$P) ;
      
      $EntryID = $PFs[$P].EntryID

   ## Permissions
      $current = Get-PublicFolderClientPermission -Identity $EntryID

  ## Anonymous
    $AnonAccess = @($current.where({ $Anonymous -eq $_.user })).accessrights
IF ($AnonymousPerm -eq $AnonAccess ) { $NewAnon = "unchanged" } else { $NewAnon = $AnonymousPerm ; $FalseAno += $Folder ;
Add-PublicFolderClientPermission -Identity $EntryID -user $Anonymous -AccessRights $AnonymousPerm -Confirm:$false }

## Default
   $defaultAccess = @($current.where({$Default -eq $_.user })).accessrights
IF ($DefaultPerm -eq $defaultAccess ) { $NewDefault = "unchanged" } else { $NewDefault = $DefaultPerm ; $FalseDef += $Folder ;
Add-PublicFolderClientPermission -Identity $EntryID -user $Default -AccessRights $DefaultPerm -Confirm:$false }

## Editors
   $Editors = @($current.where({ 'Editor' -eq $_.accessrights }));
IF($Editors) { $EditorsString = $Editors.user.displayname.ToString() -join ";" } else { $EditorsString = 'None' }

## Owners
   $Owners = @($current.where({'Owner' -eq $_.accessrights})); 
IF($Owners) { $OwnersString = $Owners.user.displayname.ToString() -join ";" } else { $OwnersString = 'None' ; $missingowner += $Folder }

        $currentdata = New-Object -TypeName PSObject       
        $currentdata | Add-Member -MemberType NoteProperty -Name Folder -Value $Folder
        $currentdata | Add-Member -MemberType NoteProperty -Name EntryID -Value $EntryID
        $currentdata | Add-Member -MemberType NoteProperty -Name anonymous -Value $AnonAccess
        $currentdata | Add-Member -MemberType NoteProperty -Name NewAnon -Value $NewAnon
        $currentdata | Add-Member -MemberType NoteProperty -Name default -Value $defaultAccess
        $currentdata | Add-Member -MemberType NoteProperty -Name NewDefault -Value $NewDefault
        $currentdata | Add-Member -MemberType NoteProperty -Name Owners -Value $OwnersString.ToString()
        $Folderdata += $currentdata
  }


$Folderdata | Export-CSV $Path -Notypeinformation -Force
