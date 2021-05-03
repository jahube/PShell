[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

wget "https://raw.githubusercontent.com/jahube/PShell/master/Phishfilter/PhishFilter.PSM1" -OutFile c:\PhishFilter.psm1

Import-Module c:\PhishFilter.psm1

Remove-AllowPhish

Add-AllowPhish

PhishView

Open-FileDialog

########################

comparedata

$Global:CompareData    # preview imported CSV to compare

$Global:FilterData     # preview filter results agains importfile

#if filter correct, declare filter as data source for below commands
$Global:Data = $Global:FilterData  

########################

