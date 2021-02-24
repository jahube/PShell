$Server = "mail.server.com"

Test-Migrationserveravailability -Excahngeremotemove -Remoteserver $Server

$req = [System.Net.HttpWebRequest]::Create("https://$Server")
$req.UseDefaultCredentials = $false
$req.GetResponse()
# Expected error: Exception calling "GetResponse" with "0" argument(s):
# "The remote server returned an error: (401) Unauthorized."
$ex = $error[0].Exception
$resp = $ex.InnerException.Response
$resp.Headers["WWW-Authenticate"]

$error[0].Exception | fl * -f

wget https://aka.ms/hybridconnectivity -OutFile c:\tm.psm1
Import-Module c:\tm.psm1
Test-HybridConnectivity -TestO365Endpoints -EA silentlycontinue

• HTTPerr logs: %SystemRoot%\System32\LogFiles\HTTPERR - Server timezone

• IIS logs for Default Web Site (DWS): %SystemDrive%\inetpub\logs\LogFiles\W3SVC1 – UTC Timezone
The name of the IIS logs contains the date of the log, for example u_ex190930.log is from Sept 30, 2019.

• HTTPProxy logs for EWS (available in Exchange 2013 or later) – UTC Timezone:
%ExchangeInstallPath%Logging\HttpProxy\Ews

The name of the HTTPProxy logs contains the date and hour starting to log, for example HttpProxy_2019093014-10.LOG (10th log from Sept 30, 2019, starting hour 14:00 UTC)
If you get a different error, let's say 401 unauthorized in test-migrationserveravailability, then you look for 401 entries for mrsproxy.svc

•	HTTPerr logs: %SystemRoot%\System32\LogFiles\HTTPERR 
•	IIS logs for Default Web Site (DWS): %SystemDrive%\inetpub\logs\LogFiles\W3SVC1 – UTC Timezone. The name of the IIS logs contains the date of the log, for example u_ex190930.log is from Sept 30, 2019. 
•	HTTPProxy logs for EWS (available in Exchange 2013 or later): %ExchangeInstallPath%Logging\HttpProxy\Ews. The name of the HTTPProxy logs contains the date and hour starting to log, for example HttpProxy_2019093014-10.LOG (10th log from Sept 30, 2019, starting hour 14:00 UTC) 
    
Here are some tips on how to use these logs:

•	Always correlate the time HH:MM:SS of the failed request with these logs (IIS and HTTPProxy are in UTC time zone) 
•	A failed request will never have 200 Status code (if you see status code 200 in logs, it means you are not looking at the failed request) 
•	If you see the failed request in HTTPerr logs, they probably won’t be present in IIS logs or HTTPProxy logs – they are stuck ‘in front of’ IIS. Check for the reason in HTTPerr logs and check for IIS misconfiguration 
•	If you see the failed requests in IIS logs , then you can do IIS failed request tracing on that status code and check further the detailed error in HTTPProxy logs
