#onprem
$A = wget "https://jahube.github.io/LOGS-Onprem.PS1"
$B = [System.Text.Encoding]::ASCII.GetString($A.Content)
$C = [scriptblock]::Create("$B") ; Invoke-Command -ScriptBlock $C

# Cloud
$A = wget "https://jahube.github.io/LOGS-ExchangeOnline.PS1"
$B = [System.Text.Encoding]::ASCII.GetString($A.Content)
$C = [scriptblock]::Create("$B") ; Invoke-Command -ScriptBlock $C