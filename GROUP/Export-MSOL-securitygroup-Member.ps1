Connect-MsolService
 
$path = "C:\temp"
mkdir $path\short
mkdir $path\complete
$DLS = Get-MsolGroup -GroupType security -All
$C = 0

$count = $DLS.count
$Members = @()
#check
foreach ($DL in $DLS) {
Write-Progress -Activity "Group $($DL.name) $($DL.Displayname)" -Status "Group $($C) / $($count)" -PercentComplete (($C/$count)*100) -SecondsRemaining "$($count-$C)" ;
$Members = @()
$ps = $path + '\short2\' + $DL.Displayname + '.csv'
$pc = $path + '\complete2\' + $DL.Displayname + '.csv'
$Members = Get-MsolGroupMember -GroupObjectId $DL.ObjectId.guid -All
$Members | Export-Csv -Path $pc -NoTypeInformation -Encoding UTF8 -Force
$Members | select DisplayName,EmailAddress,ObjectId,GroupMemberType | Export-Csv -Path $ps -NoTypeInformation -Encoding UTF8 -Force
$C++

}