
$path = "C:\temp"
mkdir $path\short
mkdir $path\complete
$DLS = Get-DistributionGroup -ResultSize unlimited
$C = 0

$count = $DLS.count
$Members = @()
#check
foreach ($DL in $DLS) {
Write-Progress -Activity "Group $($DL.name) $($DL.userprincipalname)" -Status "Group $($C) / $($count)" -PercentComplete (($C/$count)*100) -SecondsRemaining "$($count-$C)" ;
$Members = @()
$ps = $path + '\short\' + $DL.PrimarySmtpAddress + '.csv'
$pc = $path + '\complete\' + $DL.PrimarySmtpAddress + '.csv'
$Members = Get-DistributionGroupMember –Identity $DL.distinguishedname –ResultSize Unlimited
$Members | Export-Csv -Path $pc -NoTypeInformation -Encoding UTF8
$Members | select *name*,alias,pri*,GUID | Export-Csv -Path $ps -NoTypeInformation -Encoding UTF8
$C++

}