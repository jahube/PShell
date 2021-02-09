$user = "email@affected-user.com"

Set-Mailbox $user -SingleItemRecoveryEnabled $false
Set-Mailbox $user -ElcProcessingDisabled $true

# assign permissions
Add-RoleGroupMember "Compliance Management" -Member admin@domain.com

# delete items bigger than 8 MB *fast 1-10 minutes 
Search-Mailbox $user -SearchQuery size>8200000 -SearchDumpsterOnly –DeleteContent

# delete all dumpster items * slow 30 Minutes <-> 6h
Search-Mailbox $user -SearchDumpsterOnly -DeleteContent

# get RESULT
Get-MailboxFolderStatistics $user -FolderScope RecoverableItems | FL Name,FolderAndSubfolderSize,ItemsInFolderAndSubfolders