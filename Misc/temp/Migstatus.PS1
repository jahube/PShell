# Source https://medium.com/365uc/public-folder-migration-to-exchange-online-500k-folders-part-5-monitoring-and-fixing-the-sync-42eb8ba2a3c4
## Connect to Exchange Online with the prefix of Cloud
$UserName = "SERVICE ACCOUNT TO CONNECT TO EXO"
$Password = type C:\Public Folders\EXOPW.txt | ConvertTo-SecureString
$UserCredential = New-Object System.Management.Automation.PsCredential($UserName, $Password)
$EXOSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $EXOSession -AllowClobber

## Variables
$Date = Get-Date -Format yyyyMMdd-HHmmss

## Create my Arrays
$Global:MigrationStaus = @()

## Function to add results into the Array.
Function UpdateMe {
    $MS = New-Object psObject
    $MS | Add-Member -MemberType NoteProperty -Name "MMR-Identity" -Value $Mailbox.Identity
    $MS | Add-Member -MemberType NoteProperty -Name "MMR-Name" -Value $Mailbox.Name
    $MS | Add-Member -MemberType NoteProperty -Name "MBX-Server" -Value $MBX.ServerName
    $MS | Add-Member -MemberType NoteProperty -Name "MBX-Database" -Value $MBX.Database
    $MS | Add-Member -MemberType NoteProperty -Name "MMR_Stat-MRSServerName" -Value $MMR_Stat.MRSServerName
    $MS | Add-Member -MemberType NoteProperty -Name "MMR-TargetMailbox" -Value $Mailbox.TargetMailbox
    $MS | Add-Member -MemberType NoteProperty -Name "MMR-Status" -Value $Mailbox.Status
    $MS | Add-Member -MemberType NoteProperty -Name "MMR_Stat-Status" -Value $MMR_Stat.Status
    $MS | Add-Member -MemberType NoteProperty -Name "MMR_Stat-StatusDetail" -Value $MMR_Stat.StatusDetail
    $MS | Add-Member -MemberType NoteProperty -Name "MMR_Stat-SyncStage" -Value $MMR_Stat.SyncStage
    $MS | Add-Member -MemberType NoteProperty -Name "MMR_Stat-Suspend" -Value $MMR_Stat.Suspend
    $MS | Add-Member -MemberType NoteProperty -Name "MMR_Stat-LastUpdateTimestamp" -Value $MMR_Stat.LastUpdateTimestamp
    $MS | Add-Member -MemberType NoteProperty -Name "MMR_Stat-LastSuccessfulSyncTimestamp" -Value $MMR_Stat.LastSuccessfulSyncTimestamp
    $MS | Add-Member -MemberType NoteProperty -Name "MMR_Stat-InitialSeedingCompletedTimestamp" -Value $MMR_Stat.InitialSeedingCompletedTimestamp
    $MS | Add-Member -MemberType NoteProperty -Name "MMR_Stat-FinalSyncTimestamp" -Value $MMR_Stat.FinalSyncTimestamp
    $MS | Add-Member -MemberType NoteProperty -Name "MMR_Stat-CompletionTimestamp" -Value $MMR_Stat.CompletionTimestamp
    $MS | Add-Member -MemberType NoteProperty -Name "MMR_Stat-SuspendedTimestamp" -Value $MMR_Stat.SuspendedTimestamp
    $MS | Add-Member -MemberType NoteProperty -Name "MMR_Stat-TotalInProgressDuration" -Value $MMR_Stat.TotalInProgressDuration
    $MS | Add-Member -MemberType NoteProperty -Name "MMR_Stat-BytesTransferred" -Value $MMR_Stat.BytesTransferred
    $MS | Add-Member -MemberType NoteProperty -Name "MMR_Stat-ItemsTransferred" -Value $MMR_Stat.ItemsTransferred
    $MS | Add-Member -MemberType NoteProperty -Name "MMR_Stat-PercentComplete" -Value $MMR_Stat.PercentComplete
    $MS | Add-Member -MemberType NoteProperty -Name "MMR_Stat-BadItemLimit" -Value $MMR_Stat.BadItemLimit
    $MS | Add-Member -MemberType NoteProperty -Name "MMR_Stat-BadItemsEncountered" -Value $MMR_Stat.BadItemsEncountered
    $MS | Add-Member -MemberType NoteProperty -Name "MMR_Stat-LargeItemLimit" -Value $MMR_Stat.LargeItemLimit
    $MS | Add-Member -MemberType NoteProperty -Name "MMR_Stat-LargeItemsEncountered" -Value $MMR_Stat.LargeItemsEncountered
    $MS | Add-Member -MemberType NoteProperty -Name "MMR_Stat-Message" -Value $MMR_Stat.Message
	$Global:MigrationStaus += $MS
}

## Migration Discovery
$MBX = Get-Mailbox -PublicFolder | Select TargetServer,Database
$MMR = Get-PublicFolderMailboxMigrationRequest
$MMR = $MMR | Sort TargetMailbox

foreach ($Mailbox in $MMR) {
    Write-Host "Checking..." $Mailbox.TargetMailbox
    $MBX = Get-Mailbox -PublicFolder | ? {$_.Name -like $Mailbox.TargetMailbox} | Select ServerName,Database
    $MMR_Stat = Get-PublicFolderMailboxMigrationRequestStatistics $Mailbox.Identity | Select Status,StatusDetail,SyncStage,Suspend,BadItemLimit,BadItemsEncountered,LargeItemLimit,LargeItemsEncountered,LastUpdateTimestamp,LastSuccessfulSyncTimestamp,InitialSeedingCompletedTimestamp,FinalSyncTimestamp,CompletionTimestamp,SuspendedTimestamp,TotalInProgressDuration,BytesTransferred,ItemsTransferred,PercentComplete,Message,MRSServerName
    UpdateMe
}
$Global:MigrationStaus | Export-Csv "C:\Public Folders\MigrationStatus_$Date.csv" -NTI

## Remove PSSession
Remove-PSSession $EXOSession