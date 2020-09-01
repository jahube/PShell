$folders = Import-Clixml C:\Legacy_PFStructure.xml.
$folders | Get-member
$folders | Group RetainDeletedItemsFor
$folders | group ContentMailboxName
 $folders[216] | select -ExpandProperty folderpath
Set-PublicFolder


get-mailbox PFMailbox01 -i | Set-Mailbox -DefaultPublicFolderMailbox
Get-Mailbox -PublicFolder PFMailbox01 | Update-PublicFolderMailbox -InvokeSynchronizer -SuppressStatus

[216] | fl 

$folderimport.ToString()
 = $folders | select Name,ParentPath,ContentMailboxName

$folders | Export-Csv -Path C:\temp\import2.csv -NoTypeInformation -Encoding UTF8
$folders = 0

if (!($success)) { $success = New-Object System.Collections.ArrayList };

if (!($remaining)) { $remaining = New-Object System.Collections.ArrayList };
[System.Collections.ArrayList]$MBX = $folderimport; $count= $MBX.count



$param = {
Name = $P.Name
Path = $P.ParentPath
Mailbox = $P.ContentMailboxName
CF = $false
EA = "stop"
}

$errors = @()
$success = @()

$folderimport = import-Csv -Path C:\temp\import3.csv -Encoding UTF7

$PF = $folderimport; 

$count= $PF.count

$P = 1

foreach ($P in $PF) { 

$S =" [PF] ($P/$count)  [Time]"

$A = "Creating Folders [Folder Count] ($P/$count) [Folder] $($P.name)"

Write-Progress -Activity $A -Status $S -PercentComplete (($P/$count)*100) -SecondsRemaining ($count-$P) ;

Try { New-PublicFolder @param

# $PFremain.RemoveAt($PF.IndexOf("$P"))
$success += $P
} catch { 

Write-Host "`n [$($P.ContentMailboxName)] $($P.ParentPath) [ $($P.Name)] `n" -F Cyan
Write-Host "$($Error[0].Exception.Message) `n" -F Yellow
$errors += $PF[$P]
# $errors.Add(@{"Name" = "$($PF[$P].Name)"; "ParentPath" = "$($PF[$P].ParentPath)"; "ContentMailboxName" = "$($PF[$P].ContentMailboxName)"; "ExceptionMessage" = "$($Error[0].Exception.Message)"})  #add to error list
        }
$P++
}

$folderimport.name