$IP = "123.123.123.123"

Foreach($val in 0..7) { $AddVal = [math]::pow(2,$val)
[int]$IPLCeil = [int]$IP.Split(".")[-1] + [int]$AddVal
Write-host $($IP + '\' + $(32-$val))$($IP + '-' + $IPLCeil) }


$IPList = "123.123.123.123", "123.123.123.73", "123.123.123.83","123.123.123.53"

$Sorted = $IPlist | Sort-Object -descending

$Floor = [int]$Sorted[-1].Split(".")[-1] ; $Ceil = [int]$Sorted[0].Split(".")[-1]
$Range = $Ceil - $Floor ; Foreach($val in 0..7) { $AddVal = [math]::pow(2,$val)
If ($Range -le $AddVal) { $Col = "green" } else { $Col = "yellow"}
Write-host $Sorted[-1] -F cyan -N ; Write-host "$('\' + $(32-$val))  " -F $Col -N
Write-host $Sorted[-1] -F cyan -N ; Write-host "$('-' + $([int]$Floor + [int]$AddVal))  " -F $Col -N
Write-host $Range "  " -F cyan -N ; Write-host $AddVal -F $Col }