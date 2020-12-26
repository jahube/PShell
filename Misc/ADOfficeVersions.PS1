$find = {$_.Processname -eq 'OfficeClickToRun' -or $_.Processname -eq 'outlook' -or $_.Processname -eq 'Word' -or $_.Processname -eq 'Excel' } ;
$ver = { ((Get-Process).where($find))} ;
$computers = Get-ADComputer -filter * ; $data = @()
foreach ($computer in $computers) {
$obj = New-Object -TypeName PSObject
$obj | Add-Member -MemberType NoteProperty -Name Computer -Value $computer.name ;
$obj | Add-Member -MemberType NoteProperty -Name User -Value ($computer | icm { whoami}) ;
Try { $apps = $computer | icm $ver -ErrorAction Stop ; 
$apps = $apps | sort-object Processname, ProductVersion -Unique ;
Foreach ($app in $apps) { $obj | Add-Member -MemberType NoteProperty -Name $app.Processname -Value $app.ProductVersion } ;
} catch {  $obj | Add-Member -MemberType NoteProperty -Name OfficeClickToRun -Value = 'notfound' } ;
$data +=  $obj } 
$data


$ver = {(Get-Process).where({$_.Processname -eq 'OfficeClickToRun' -or $_.Processname -eq 'outlook' -or $_.Processname -eq 'Word' -or $_.Processname -eq 'Excel' })}
$computers = Get-ADComputer -filter * ; $data = @()
foreach ($computer in $computers) {  
$session = New-PSSession -ComputerName $computer.name
$whoami = ICM -Session $session -ScriptBlock { whoami}
$obj = New-Object -TypeName PSObject
$obj | Add-Member -MemberType NoteProperty -Name Computer -Value $computer.name
$obj | Add-Member -MemberType NoteProperty -Name User -Value $whoami
Try { $apps = invoke-command -Session $session -ScriptBlock $ver -ErrorAction Stop ; 
$apps = $apps | sort-object Processname, ProductVersion -Unique
Foreach ($app in $apps) { $obj | Add-Member -MemberType NoteProperty -Name $app.Processname -Value $app.ProductVersion }
} catch {  $obj | Add-Member -MemberType NoteProperty -Name OfficeClickToRun -Value = 'notfound' }
Remove-PSSession $session
$data +=  $obj } 
$data

$filter = {$_.Processname -eq 'OfficeClickToRun' -or $_.Processname -eq 'outlook' -or $_.Processname -eq 'Word' -or $_.Processname -eq 'Excel' }
$ver = {(Get-Process).where($filter)}
$computers = Get-ADComputer -filter * ; $data = @()
foreach ($computer in $computers) {  
$session = New-PSSession -ComputerName $computer.name
$whoami = ICM -Session $session -ScriptBlock { whoami}
$obj = New-Object -TypeName PSObject
$obj | Add-Member -MemberType NoteProperty -Name Computer -Value $computer.name
$obj | Add-Member -MemberType NoteProperty -Name User -Value $whoami
Try { $apps = invoke-command -Session $session -ScriptBlock $ver -ErrorAction Stop ; 
$apps = $apps | sort-object Processname, ProductVersion -Unique
Foreach ($app in $apps) { $obj | Add-Member -MemberType NoteProperty -Name $app.Processname -Value $app.ProductVersion }
} catch {  $obj | Add-Member -MemberType NoteProperty -Name OfficeClickToRun -Value = 'notfound' }
Remove-PSSession $session
$data +=  $obj } 
$data