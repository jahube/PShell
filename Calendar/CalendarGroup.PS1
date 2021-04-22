$group = Get-DistributionGroup | where { $_.recipienttype -eq "MailUniversalSecurityGroup" } | Out-GridView -T "select Group" -OutputMode Single
$Access = "LimitedDetails", "AvailabilityOnly", "Reviewer"  | Out-GridView -T "select Access Level" -OutputMode Single
Foreach ($M in Get-DistributionGroupMember $group.distinguishedname) {
Foreach ($F in (get-MailboxFolderStatistics $M.alias | ? {$_.foldertype.tostring() -eq "Calendar"}))
        {$FN = $M.alias + ':' + $F.FolderPath.Replace('/','\')
        Try { Add-MailboxFolderPermission $FN -User $group.distinguishedname -AccessRights $Access -EA stop
              write-host "`nADD [$FN] - $Access - [$($group.Name)] Successful" -F green }
      catch { write-host "Failed [$FN]" $Error[0].Exception.message -F yellow } } }