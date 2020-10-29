duplicate PF MigrationRequest deletion

https://social.technet.microsoft.com/Forums/msonline/en-US/d37d09d8-c9c2-4e84-9426-f7f83d5b7fd7/newmailboximportrequest-creates-double-identical-entry-how-to-remove

$p = Get-PublicFolderMailboxMigrationRequest

Foreach ($r in $p) { Remove-PublicFolderMailboxMigrationRequest –RequestGuid "$($r.RequestGuid)" -RequestQueue "$($r.RequestQueue)" -Confirm:$false -Force } 

Get-PublicFolderMailboxMigrationRequest -identity \PublicFolderMailboxMigrationf1451846-c917-4c3a-95bd-de251d96146c  | select RequestGuid, RequestQueue
 
Remove-PublicFolderMailboxMigrationRequest –RequestGuid <request guid> –RequestQueue <request queue>

$d = Get-PublicFolderMailboxMigrationRequest | group TargetMailbox | ?{$_.Count -gt 1}

Remove-PublicFolderMailboxMigrationRequest –RequestGuid $d[0].RequestGuid.ToString() –RequestQueue $d[0].RequestQueue.ToString() 