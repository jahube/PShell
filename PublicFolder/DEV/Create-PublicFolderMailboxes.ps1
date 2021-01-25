$PFcount = "30"
$Prefix = "PF"

$PFNameArray = @() ; for ($N = 1; $N -le $PFcount ; $N++) { 
if ($N -le "9") { [String]$name = [String]$($Prefix + '0' + $N) }
Else            { [String]$name = [String]$($Prefix + $N) }
$PFNameArray += $name }

$command = @'
Param($P) ;
for ($P = 0; $P -lt $PFNameArray.count; $P++) { new-Mailbox -PublicFolder -Name $PFNameArray[$P] }
'@

#$session = Get-PSSession -InstanceId (Get-OrganizationConfig).RunspaceId.Guid
$myscriptblock = [scriptblock]::Create("$command")
Invoke-Command -ScriptBlock $myscriptblock -ArgumentList $PFNameArray