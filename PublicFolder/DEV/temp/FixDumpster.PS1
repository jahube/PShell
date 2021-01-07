
$org=<organization_name which is affected>

#To Fix all the folders in this organization, use the following cmdlet
FixFolderswithInvalidDumpsters -org $org
 
#To fix certain folders, use the following cmdlet (a list of "<Identity>" will also work, instead of EntryIds)
$entryIds = @("entryId1","entryId2")
FixFolderswithInvalidDumpsters -org $org -entryIds $entryIds 
 
function FixFolderswithInvalidDumpsters
{
    [CmdletBinding()]  
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $org,
 
        [Parameter(Mandatory=$false)]
        [string[]]$entryIds=$null
    )
 
    "PublicFolder,ContentMailbox" >> FoldersWithInvalidDumpster.csv;
    "PublicFolder,ContentMailbox,UpdateContentMailbox" >> ContentMailboxOverridden2.csv
 
    if ($entryIds -eq $null)
    {
        #To Fix all the folders in this organization, use the following cmdlet
        $pfs=Get-PublicFolder -Recurse -ResultSize Unlimited -Organization $org -ErrorAction Stop;
    }
    else
    {
        #To fix certain folders, use the following cmdlet (a list of "<Identity>" will also work, instead of EntryIds)
        $pfs=$entryIds | Get-PublicFolder -recurse -Organization $org -ErrorAction Stop;
    }
 
    Foreach($pf in $pfs)
    {
        $l = "Processing " + $pf.Identity;
        $l >> "Processing.txt"
        echo $l;
        $d = Get-PublicFolder -Organization $org $pf.DumpsterEntryId;
        if($d -eq $null)
        {
            $log = "$($pf.Identity)" + ";" + "$($pf.ContentMailboxName)";
            $log >> FoldersWithInvalidDumpster.csv;
            Update-PublicFolderMailbox $org\$($pf.ContentMailboxName) -FolderId "$org\$($pf.Identity)" -CreateAssociatedDumpster -InvokeSynchronizer;
            $l2 = "Fixed " + $pf.Identity;
            $pf.Identity + ";" + $pf.ContentMailboxName >> "Fixed.csv"
            echo $l2;
            $pf2 = Get-PublicFolder $org\$($pf.Identity)
            if($pf.ContentMailboxName -ne $pf2.ContentMailboxName)
            {
                Set-PublicFolder -Identity $org\$($pf.Identity) -OverrideContentMailbox $org\$($pf.ContentMailboxName) -Force
                $log2 = $pf.Identity + "," + $pf.ContentMailboxName + "," + $pf2.ContentMailboxName
                $log2 >> ContentMailboxOverridden2.csv
                echo "Mailbox overridden:" $log
            }
        }
        elseif($d.ContentMailboxGuid.Guid -ne $pf.ContentMailboxGuid.Guid)
        {
             $log3 = "$($pf.Identity)" + ";" + "$($pf.ContentMailboxName)" + " Dumpster in different mailbox";
             echo $log3;
             #$mbxs = Get-Mailbox -PublicFolder -Organization $org -ResultSize 5;
             #$candidate = $mbxs[1..4] | ?{$_.ExchangeGuid.Guid -ne $d.ContentMailboxGuid.Guid} | ?{$_.ExchangeGuid.Guid -ne $pf.ContentMailboxGuid.Guid}
             #New-PublicFolderMoveRequest -Folders $pf.EntryId -TargetMailbox $candidate[0].ExchangeGuid.Guid -Organization $org
             #echo "Tried to issue new move request to another mailbox. If failed, please retry after completion of any existing move requests."
Set-PublicFolder -Identity $org\$($d.Identity) -OverrideContentMailbox $org\$($pf.ContentMailboxName) -Force
 
        }
    }
} 
 
