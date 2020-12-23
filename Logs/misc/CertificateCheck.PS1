$fqdn = "exchange.server.com"
$port = "443"
$ProtocolName = "tls12"
$Socket = [System.Net.Sockets.Socket]::new([System.Net.Sockets.SocketType]::Stream, [System.Net.Sockets.ProtocolType]::Tcp)
Write-host "Attempting socket connection to $fqdn`:$port" -F yellow
$Socket.Connect($fqdn, $Port)
Write-Verbose "Connection succeeded."
$NetStream = [System.Net.Sockets.NetworkStream]::new($Socket, $true)
$SslStream = [System.Net.Security.SslStream]::new($NetStream, $true, { $true }) # Ignore certificate validation errors
Write-Host "Attempting to authenticate to $fqdn as a client over $ProtocolName" -F yellow
$SslStream.AuthenticateAsClient($fqdn, $null, $ProtocolName, $false)
$Certificate = $SslStream.RemoteCertificate
$Certificate = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList $Certificate
$Certificate.Extensions | %{New-Object Security.Cryptography.Oid $_.oid } |ft
$Certificate | fl
$Certificate.Extensions 
[System.Security.Cryptography.X509Certificates.X509Certificate2]$SslStream.RemoteCertificate |fl

# Reference: http://digicert.com/help
# https://dev.digicert.com/services-api/certificates/list-intermediates/
# https://dev.digicert.com/custom-reports-api/