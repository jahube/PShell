wget https://aka.ms/hybridconnectivity -OutFile c:\tm.psm1
Import-Module c:\tm.psm1
Test-HybridConnectivity -TestO365Endpoints -EA silentlycontinue