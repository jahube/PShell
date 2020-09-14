$folders = Import-Clixml "C:\temp\Legacy_PFStructure.xml"
$folders | Get-member
$folders | Group RetainDeletedItemsFor
$folders | group ContentMailboxName
 $folders[216] | select -ExpandProperty folderpath
Set-PublicFolder


get-mailbox PFMailbox01 -i | Set-Mailbox -DefaultPublicFolderMailbox
Get-Mailbox -PublicFolder PFMailbox01 | Update-PublicFolderMailbox -InvokeSynchronizer -SuppressStatus

[216] | fl 

$folderimport.ToString()
$folderimport = $folders | select Name,ParentPath,ContentMailboxName

$folderimport | Export-Csv -Path C:\temp\import3.csv -NoTypeInformation -Encoding UTF8


if (!($success)) { $success = New-Object System.Collections.ArrayList };

if (!($remaining)) { $remaining = New-Object System.Collections.ArrayList };
$MBX = $folderimport; $count= $MBX.count
$MBX[1]


$param = @{
Name = $($PF[$P].Name)
Path = $($PF[$P].ParentPath)
Mailbox = $($PF[$P].ContentMailboxName)
CF = $false
EA = "stop"
}


$folderimport = import-Csv -Path C:\temp\import3.csv -Encoding UTF8

[System.Collections.ArrayList]$PF = $folderimport; $count= $PF.count

[System.Collections.ArrayList]$PFremain = $PF

# $errors = New-Object System.Collections.ArrayList
$errors = @()

for ($P = 0; $P -lt $PF.count; $P++) { 

$S =" [PF] ($($P+1)/$count)  [Time]"

$A = "Creating Folders [Folder Count] ($($P+1)/$count) [PFMBX] $($PF[$P].ContentMailboxName) [PARENT] $($PF[$P].ParentPath) [Folder] $($PF[$P].Name) "

Write-Progress -Activity $A -Status $S -PercentComplete (($P/$count)*100) -SecondsRemaining ($count-$P) ;

Try { 
#New-PublicFolder -Name $PF[$P].Name -Path $PF[$P].ParentPath -Mailbox $PF[$P].ContentMailboxName -CF:$false -EA 'stop'

New-PublicFolder @param

#$PFremain.RemoveAt($PF.IndexOf($P))

} catch { 

Write-Host "`n [$($PF[$P].ContentMailboxName)] $($PF[$P].ParentPath) [$($PF[$P].Name)] `n" -F Cyan
Write-Host "$($Error[0].Exception.Message) `n" -F Yellow

$errors += $PF[$P]
#$errors.Add(@{"Name" = "$($PF[$P].Name)"; "ParentPath" = "$($PF[$P].ParentPath)"; "ContentMailboxName" = "$($PF[$P].ContentMailboxName)"})  #add to error list ; "ExceptionMessage" = "$($Error[0].Exception.Message)
        }

}



Get-PublicFolder -Recurse
New-PublicFolder -Name "Amsterdam Client Filing" -Path "\Sanne Trust" -Mailbox "PFMailbox01"