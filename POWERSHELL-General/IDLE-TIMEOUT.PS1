# NOTE - these settings are absolute MAX mailnly for TESTING #

# extend idle timeout to 50 days 
# max download 500 MB / 50 MB per command

##################################

$option = New-PSSessionOption -IdleTimeout "4300000" -MaximumRedirection 5 -Culture "DE-DE" -OpenTimeout "4300000" -MaxConnectionRetryCount "1000" -OperationTimeout "4300000" -SkipRevocationCheck -MaximumReceivedObjectSize 500MB -MaximumReceivedDataSizePerCommand 50MB

Connect-ExchangeOnline -UserPrincipalName admin@domain.com -PSSessionOption $option

##################################
# alternative as parameter array #
##################################

$admin = "admin@domain.com"

$sessionoptions = @{

IdleTimeout = "4300000" ;
MaximumRedirection = "5" ;
Culture = "DE-DE" ;
OpenTimeout = "4300000" ;
MaxConnectionRetryCount = "1000" ;
OperationTimeout = "4300000" ;
SkipRevocationCheck = $true ;
MaximumReceivedObjectSize = "500MB" ;
MaximumReceivedDataSizePerCommand = "50MB" ;

}

$options = New-PSSessionOption @sessionoptions

Connect-ExchangeOnline -UserPrincipalName $admin -PSSessionOption $options

##################################