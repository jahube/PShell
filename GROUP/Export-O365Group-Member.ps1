
$path = "C:\temp"
mkdir $path\short
mkdir $path\complete
$Groups = Get-UnifiedGroup -ResultSize unlimited
$C = 0

$count = $DLS.count
$Members = @()
#check
foreach ($G in $Groups) {
Write-Progress -Activity "Group $($DL.name) $($DL.userprincipalname)" -Status "Group $($C) / $($count)" -PercentComplete (($C/$count)*100) -SecondsRemaining "$($count-$C)" ;
$Members = @()
$ps = $path + '\short\' + $DL.PrimarySmtpAddress + '.csv'
$pc = $path + '\complete\' + $DL.PrimarySmtpAddress + '.csv'

$Groupmembers = Get-UnifiedGroupLinks -Identity $G.ExternalDirectoryObjectId -LinkType Member
$Groupmembers | Export-csv "$GroupDirPath\Groupmembers-$Groupdirname.CSV" -NoTypeInformation
$Groupmembers | Export-Clixml "$GroupDirPath\Groupmembers-$Groupdirname.XML"
$Groupmembers | FT > "$GroupDirPath\Groupmembers-$Groupdirname.txt"

$GroupOwners = Get-UnifiedGroupLinks -Identity $G.ExternalDirectoryObjectId -LinkType Owner
$GroupOwners | Export-csv "$GroupDirPath\GroupOwners-$Groupdirname.CSV" -NoTypeInformation
$GroupOwners | Export-Clixml "$GroupDirPath\GroupOwners-$Groupdirname.XML"
$GroupOwners | FT > "$GroupDirPath\GroupOwners-$Groupdirname.txt"

$C++

}