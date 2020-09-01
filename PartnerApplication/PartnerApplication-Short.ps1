# if not successful refer to the long versions in parent folder

$exch = [Microsoft.Exchange.Data.Directory.SystemConfiguration.WellknownPartnerApplicationIdentifiers]::Exchange;
$exchApp = Get-PartnerApplication $exch
$exchAppName = “Exchange Online”
$appAccountName = $exchApp.Name + “-ApplicationAccount”;
$appAccount = Get-LinkedUser -Identity $appAccountName –ErrorAction
Set-PartnerApplication -Identity $exchApp.Identity -LinkedAccount $appAccount.Identity