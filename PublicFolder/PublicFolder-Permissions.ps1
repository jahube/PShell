
Public Folder Permissions

######################################################
#           Security group, best option              #
######################################################
$folderscope = '\' ;

$permission = 'Editor' ;

$Groupname = 'test20200806150306' ;

$Group = (Get-DistributionGroup $Groupname).Distinguishedname ;

$PFs = get-publicfolder $folderscope -Recurse -ResultSize unlimited -EA silentlycontinue ;

[System.Collections.ArrayList]$PF = $PFs.identity ; $count= $PF.count ;

for ($P = 0; $P -lt $count; $P++) { 

Write-Progress -Activity "Add pemission ($permission) - current Folder" -Id 2 -ParentId 1 -Status $PF[$P] -PercentComplete (($P/$count)*100) -SecondsRemaining (($count-$P)*3) ;

Add-PublicFolderClientPermission -Identity $PF[$P] -user $Group -AccessRights $permission -Confirm:$false ;

}

######################################################
#Short Remove/ Add $permission USERLIST
######################################################

$MBX = @("User1@DOMAIN.com","User2@DOMAIN.com") ;

$folderscope = '\' ;

$permission = 'Editor' ;

$PFs = get-publicfolder $folderscope -Recurse ;

[System.Collections.ArrayList]$PF = $PFs.identity ;
if (!($success)) { $success = New-Object System.Collections.ArrayList }
if (!($errors)) { $errors = New-Object System.Collections.ArrayList }
$Mcnt= $MBX.count ; $count= $PF.count ;
for ($M = 0; $M -lt $MBX.count; $M++) { 
Write-Progress -Activity "Remove/ Add $permission - current Mailbox" -Id 1 -Status $MBX[$M] -PercentComplete (($M/$Mcnt)*100) ;
for ($P = 0; $P -lt $PF.count; $P++) { 
Write-Progress -Activity "Remove/ Add $permission - current Folder" -Id 2 -Status $PF[$P] -PercentComplete (($P/$count)*100) ;
Remove-PublicFolderClientPermission -Identity $PF[$P] -user $MBX[$M] -Confirm:$false -ErrorAction silentlycontinue ;
Try { Add-PublicFolderClientPermission -Identity $PF[$P] -user $MBX[$M] -AccessRights $permission -Confirm:$false -EA stop ;
}catch{
$Fail += $MBX[$M] ;
Write-host "$($MBX[$M]) ADD fail" -F yellow ;
Write-host $Error[0].Exception.Message -F yellow ;
      }
   }
}
######################################################
# all mailboxes excluding Admin list * better check security group / first option
######################################################
$permission = 'Editor';

$folderscope = '\';
##### doublecheck folder list + Error list exist #####
if (!($success)) { $success = New-Object System.Collections.ArrayList };
if (!($errors)) { $errors = New-Object System.Collections.ArrayList };
if (!($PFs)) { $PFs = get-publicfolder $folderscope –Recurse  };
if (!($PF)) { [System.Collections.ArrayList]$PF = $PFs.identity };
if (!($count)) { $count= $PF.count };
######################################################

################ all mailbox array ####################

$MBXs = get-mailbox -ResultSize unlimited ;

[System.Collections.ArrayList]$MBX = $MBXs.userprincipalname ;

################# exclude admins ######################

[System.Collections.ArrayList]$admins = "admin@edu.dnsabr.com", “admin2@edu.dnsabr.com” ;
write-host "$($MBX.count) Users" -F yellow ;
foreach ($adm in $admins) { write-host "$adm removed" -F Green ;
$MBX.RemoveAt($MBX.IndexOf("$adm")) } ; 
write-host "$($MBX.count) Users" -F Green ;

######################################################

$Mcnt= $MBX.count ; $count= $PF.count ;

$stopwatchM = [system.diagnostics.stopwatch]::startNew()
for ($M = 0; $M -lt $MBX.count; $M++) { 
# $PStimeout = [system.diagnostics.stopwatch]::startNew()
# Try{ Connect-ExchangeOnline -Credential $cred -EA stop } catch { Connect-ExchangeOnline -UserPrincipalName $admin }
$TimeM = ($($stopwatchM.Elapsed.TotalSeconds)/($M/$Mcnt))*(1-($M/$Mcnt))
If ($TimeM -gt 99999) { $TimeM = (($($count) * 4)* $($Mcnt))}
Write-Progress -Activity "Re-Adding $permission - #users [$($M)] / total [$($Mcnt)] } " -Id 1 -Status "[User: $($MBX[$M]) ] [$($M)/$($Mcnt)] - overall Time" -PercentComplete (($M/$Mcnt)*100) -SecondsRemaining $TimeM ;
$stopwatchP = [system.diagnostics.stopwatch]::startNew()
for ($P = 0; $P -lt $PF.count; $P++) { 
$TimeP = ($($stopwatchP.Elapsed.TotalSeconds)/($P/$count))*(1-($P/$count))
#If ($($PStimeout.Elapsed.TotalMinutes) -gt "40") { 
#Try{ Connect-ExchangeOnline -Credential $cred -EA stop } catch { Connect-ExchangeOnline -UserPrincipalName $admin }
#$PStimeout = [system.diagnostics.stopwatch]::startNew() }
if (!(Get-PSSession | Where { $_.ConfigurationName -eq "Microsoft.Exchange" })) { 
Try{ Connect-ExchangeOnline -Credential $cred -EA stop } catch { Connect-ExchangeOnline -UserPrincipalName $admin }}

If ($TimeP -gt 99999) { $TimeP = ($($count) * 4) }
Write-Progress -Activity "Remove/ Add $permission - Status [current Folder] + " -Id 2 -Status "User: $($MBX[$M]) Folder: [$($PF[$P])] [current user] - Time" -PercentComplete (($P/$count)*100) -SecondsRemaining $TimeP ;

Remove-PublicFolderClientPermission -Identity $PF[$P] -user $MBX[$M] -Confirm:$false -ErrorAction silentlycontinue ;

Try { Add-PublicFolderClientPermission -Identity $PF[$P] -user $MBX[$M] -AccessRights $permission -Confirm:$false -EA stop;

$success.Add(@{"user" = "$($MBX[$M])"; "folder" = "$($PF[$P])"; "permission" = "$permission"; "status" = "successful"}) #add to results

}catch{

$errors.Add(@{"user" = "$($MBX[$M])"; "folder" = "$($PF[$P])"; "permission" = "$permission"; "status" = "failed"})  #add to error list
Write-host "Failed to add `n Permission: $($permission) `n User: $($MBX[$M]) `n Folder: [ $($PF[$P]) ]" -F yellow; 
Write-host $Error[0].Exception.Message -F yellow;
      }
   }
}

######################################################
#Short Remove/ Add Anonymous (none)
######################################################
$permission = 'none';
$usr = 'Anonymous'
$folderscope = '\';
##### doublecheck folder list + Error list exist #####
if (!($success)) { $success = New-Object System.Collections.ArrayList };
if (!($errors)) { $errors = New-Object System.Collections.ArrayList };
if (!($PFs)) { $PFs = get-publicfolder $folderscope –Recurse  };
if (!($PF)) { [System.Collections.ArrayList]$PF = $PFs.identity };
if (!($count)) { $count= $PF.count };
######################################################

for ($P = 0; $P -lt $PF.count; $P++) { 

Write-Progress -Activity "Remove/ Add Anonymous (none) - current Folder" -Id 2 -ParentId 1 -Status $PF[$P] -PercentComplete (($P/$count)*100);

Remove-PublicFolderClientPermission -Identity $PF[$P] -user $usr -Confirm:$false -ErrorAction silentlycontinue;

Try { 

Add-PublicFolderClientPermission -Identity $PF[$P] -user $usr -AccessRights $permission -Confirm:$false -EA stop;

$success.Add(@{"user" = "$usr"; "folder" = "$($PF[$P])"; "permission" = "$permission"; "status" = "successful"}) #add to results

}catch{

$errors.Add(@{"user" = "$usr"; "folder" = "$($PF[$P])"; "permission" = "$permission"; "status" = "failed"})  #add to error list
Write-host "Failed to add `n Permission: $($permission) `n User: $($MBX[$M]) `n Folder: [ $($PF[$P]) ]" -F yellow; 
Write-host $Error[0].Exception.Message -F yellow;
    }
}

######################################################
#Short Remove/ Add Default (Author)
######################################################
$permission = 'Author';
$usr = 'Default';
$folderscope = '\';
##### doublecheck folder list + Error list exist #####
if (!($success)) { $success = New-Object System.Collections.ArrayList };
if (!($errors)) { $errors = New-Object System.Collections.ArrayList };
if (!($PFs)) { $PFs = get-publicfolder $folderscope –Recurse  };
if (!($PF)) { [System.Collections.ArrayList]$PF = $PFs.identity };
if (!($count)) { $count= $PF.count };
######################################################

for ($P = 0; $P -lt $PF.count; $P++) { 

Write-Progress -Activity "Remove/ Add Default (Author) - current Folder" -Id 2 -ParentId 1 -Status $PF[$P] -PercentComplete (($P/$count)*100);

Remove-PublicFolderClientPermission -Identity $PF[$P] -user $usr -Confirm:$false -ErrorAction silentlycontinue;

Try { 

Add-PublicFolderClientPermission -Identity $PF[$P] -user $usr -AccessRights $permission -Confirm:$false -EA stop #add

$success.Add(@{"user" = "$usr"; "folder" = "$($PF[$P])"; "permission" = "$permission"; "status" = "successful"}) #add to results

}catch{

$errors.Add(@{"user" = "$usr"; "folder" = "$($PF[$P])"; "permission" = "$permission"; "status" = "failed"})  #add to error list
Write-host "Failed to add `n Permission: $($permission) `n User: $($MBX[$M]) `n Folder: [ $($PF[$P]) ]" -F yellow; 
Write-host $Error[0].Exception.Message -F yellow;
    }
}

#####################################
$path 

$output = @()
foreach ($s in $success) {

$obj = New-Object PSObject -Property @{            
          user = $s.user                
        folder = $s.folder              
    permission = $s.permission
        status = $s.status           
    }    
$output+= $obj
}      

$output | Export-Csv -Path C:\temp\resut.csv -NoTypeInformation -Encoding UTF8
$output | group permission,user | select count,name

if (!(Get-PSSession | Where-Object { ($_.ConfigurationName -eq "Microsoft.Exchange") }
