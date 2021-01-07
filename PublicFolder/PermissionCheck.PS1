$folderscope = '\'

$success = New-Object System.Collections.ArrayList
$errors = New-Object System.Collections.ArrayList
$PFs = get-publicfolder $folderscope –Recurse
#$PS = $PFs | Get-PublicFolderClientPermission
#$PS = $PS | ? { ($_.user.displayname -notmatch "Default") -and ($_.user.displayname -notmatch "Anonymous") }
$count = $PFs.count ; $err = @() ; $data = @()
for ($P = 0; $P -lt $PFs.count; $P++) { 
$F = $PFs[$P].identity.ToString()
$DN = $PS[$P].user.displayname.ToString()
#$DST = $PS[$P].user.RecipientPrincipal
#$AR = $PS[$P].accessrights
$SPF = $PS[$P].SharingPermissionFlags
Write-Progress -Activity "Remove permission - [current Folder] $($F)" -Id 2 -ParentId 1 -Status "For [USER] $($DN)" -PercentComplete (($P/$count)*100) -SecondsRemaining $($count-$P) ;

       $current = Get-PublicFolderClientPermission -Identity $F
       $default = $current.where({'default' -eq $_.user })
     $anonymous = $current.where({'anonymous' -eq $_.user }) ; $ano = $anonymous.accessrights
        $Editor = $current.where({'Editor' -eq $_.accessrights })
        $Owners = $current.where({'Owner' -eq $_.accessrights }) ; $Own = $Owners.user

IF ("Createitems" -eq $ano ) {  $AnonAccess = $ano ; $NewAnon = "unchanged" } else { $ano}
IF ($Owners) { $Ownerstring = [system.String]::Join(";", $Own) }

        $folder = New-Object -TypeName PSObject       
        $folder | Add-Member -MemberType NoteProperty -Name Folder -Value $F
        $folder | Add-Member -MemberType NoteProperty -Name EntryID -Value $F
        $folder | Add-Member -MemberType NoteProperty -Name anonymous -Value $AnonAccess
        $folder | Add-Member -MemberType NoteProperty -Name NewAnon -Value $NewAnon
        $folder | Add-Member -MemberType NoteProperty -Name default -Value $default.accessrights
        $folder | Add-Member -MemberType NoteProperty -Name NewDefault -Value $cal
        $folder | Add-Member -MemberType NoteProperty -Name Owners -Value $Ownerstring
        $data += $folder
  }


| Remove-PublicFolderClientPermission -ErrorAction silentlycontinue
}

# get-publicfolder \ -Recurse | Get-PublicFolderClientPermission | Remove-PublicFolderClientPermission