
OAUTH-LOGS

# ONE-LINER

# onprem
ICM $([scriptblock]::Create([System.Text.Encoding]::ASCII.GetString((wget "https://jahube.github.io/LOGS-Onprem.PS1").Content)))

# Cloud
ICM $([scriptblock]::Create([System.Text.Encoding]::ASCII.GetString((wget "https://jahube.github.io/LOGS-ExchangeOnline.PS1").Content)))


# 2 Line Version
# onprem
$A = wget "https://jahube.github.io/LOGS-Onprem.PS1"
ICM $([scriptblock]::Create("$([System.Text.Encoding]::ASCII.GetString($A.Content))"))

# Cloud
$A = wget "https://jahube.github.io/LOGS-ExchangeOnline.PS1"
ICM $([scriptblock]::Create("$([System.Text.Encoding]::ASCII.GetString($A.Content))"))


# 3 Line Version
# onprem
$A = wget "https://jahube.github.io/LOGS-Onprem.PS1"
$B = [System.Text.Encoding]::ASCII.GetString($A.Content)
$C = [scriptblock]::Create("$B") ; Invoke-Command -ScriptBlock $C

# Cloud
$A = wget "https://jahube.github.io/LOGS-ExchangeOnline.PS1"
$B = [System.Text.Encoding]::ASCII.GetString($A.Content)
$C = [scriptblock]::Create("$B") ; Invoke-Command -ScriptBlock $C