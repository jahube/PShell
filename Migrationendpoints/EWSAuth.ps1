# Source https://techcommunity.microsoft.com/t5/exchange-team-blog/troubleshooting-hybrid-migration-endpoints-in-classic-and-modern/ba-p/953006

$req = [System.Net.HttpWebRequest]::Create("https://mail.contoso.com/ews/MRSProxy.svc")
$req.UseDefaultCredentials = $false
$req.GetResponse()
# Expected error: Exception calling "GetResponse" with "0" argument(s):
# "The remote server returned an error: (401) Unauthorized."
$ex = $error[0].Exception
$resp = $ex.InnerException.Response
$resp.Headers["WWW-Authenticate"]



$error[0].Exception | fl * -f