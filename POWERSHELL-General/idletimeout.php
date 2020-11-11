extend idle timeout to 50 days

max download 500 MB / 50 MB per command
 
$option = New-PSSessionOption -IdleTimeout "4300000" -MaximumRedirection 5 -Culture "DE-DE" -OpenTimeout "4300000" -MaxConnectionRetryCount "1000" -OperationTimeout "4300000" -SkipRevocationCheck -MaximumReceivedObjectSize 500MB -MaximumReceivedDataSizePerCommand 50MB

Connect-ExchangeOnline -UserPrincipalName admin@edu.dnsabr.com -PSSessionOption $option