# MSOL Alias search

$UPN = "<UPN>"

$Proxies = Get-MsolUser -UserPrincipalName $UPN | select proxyaddresses -ExpandProperty ProxyAddresses 
ForEach ($Proxy in $Proxies){ 
    $ProxyF = $proxy.toLower().trimstart("smtp:") 
    Write-host "Searching Proxy: "$ProxyF 
    $Users = Get-MsolUser -all | Where-Object {$_.ProxyAddresses -match "$ProxyF"} 
    $Users.UserPrincipalName 
} 

# MSOL Alias search softdeleted

$Proxies = Get-MsolUser -UserPrincipalName $UPN -returndeletedusers | select proxyaddresses -ExpandProperty ProxyAddresses 
ForEach ($Proxy in $Proxies){ 
    $ProxyF = $proxy.toLower().trimstart("smtp:") 
    Write-host "Searching softdeleted Proxy: "$ProxyF 
    $Users = Get-MsolUser -returndeletedusers -all | Where-Object {$_.ProxyAddresses -match "$ProxyF"} 
    $Users.UserPrincipalName 
} 
