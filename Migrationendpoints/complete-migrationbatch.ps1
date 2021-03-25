
1) one by one

remove-migrationuser -identity "migrationuser" -force

2) just in case .. all failed migration users - no need if above successful but to double-check

$failedusers =  get-migrationuser | where { $_.status -eq 'failed' }
$failedusers | % { remove-migrationuser -identity $_.identity -force -confirm:$true }

3) the moverequests should be already removed when the migration users are deleted - just in case

get-moverequest -MoveStatus Failed | remove-moverequest

5) also just in case as above would do it "automatically"
get-MigrationBatch | where { $_.status -eq 'CompletedWithErrors' } | Remove-MigrationBatch -CF:$false

get-MigrationBatch | where { $_.status -eq 'Completed' } | Remove-MigrationBatch -CF:$false

get-MigrationBatch | where { $_.status -eq 'synced' } | Set-MigrationBatch -CompleteAfter (Get-Date).ToUniversalTime()

# get-MigrationBatch | where { $_.status -eq 'synced' } | Complete-MigrationBatch -SyncAndComplete -CF:$false

###############################

remove failed migrationusers
$failedusers =  get-migrationuser | where { $_.status -eq 'synced' }
$failedusers | % { Set-migrationuser -identity $_.identity -approveskippeditems -CF:$true }
$failedusers | % { Set-migrationuser -identity $_.identity -CompleteAfter (Get-Date).ToUniversalTime() -CF:$true }

remove failed migrationusers
$failedusers =  get-migrationuser | where { $_.status -eq 'failed' }
$failedusers | % { remove-migrationuser -identity $_.identity -force -CF:$true }

  Set Completion time for synced with errors
$failedmigrationbatch =  get-MigrationBatch | where { $_.status -eq 'CompletedWithErrors' }
$failedmigrationbatch |% { Set-MigrationBatch -identity $_.identity.ToString() -CompleteAfter (Get-Date).ToUniversalTime() -CF:$true }

 remove failed batches
$failedmigrationbatch =  get-MigrationBatch | where { $_.status -eq 'failed' }
$failedmigrationbatch | % { remove-MigrationBatch -identity $_.identity.ToString() -CF:$true }

 remove aready completed batches
$failedmigrationbatch =  get-MigrationBatch | where { $_.status -eq 'Completed' }
$failedmigrationbatch | % { remove-MigrationBatch -identity $_.identity.ToString() -CF:$true }

 Set Completion time
$failedmigrationbatch =  get-MigrationBatch | where { $_.status -eq 'synced' }
$failedmigrationbatch | % { Set-MigrationBatch -identity $_.identity.ToString() -CompleteAfter (Get-Date).ToUniversalTime() -CF:$true }

 manual complete
$failedmigrationbatch =  get-MigrationBatch | where { $_.status -eq 'synced' }
$failedmigrationbatch | % { Complete-MigrationBatch -identity $_.identity.ToString() -SyncAndComplete -CF:$true }
