
$Addr = "IMCEAEX insert here"

$Repl= @(@("_","/"), @("\+20"," "), @("\+28","("), @("\+29",")"), @("\+2C",","), @("\+5F", "_" ), @("\+40", "@" ), @("\+2E", "." ))

$Repl | ForEach { $Addr= $Addr -replace $_[0], $_[1] }

$Addr= "X500:$Addr" -replace "IMCEAEX-","" -replace "@.*$", ""

Write-Host $Addr


# source  https://www.o-xchange.com/2014/07/script-for-converting-bounce-back.html
# https://gallery.technet.microsoft.com/office/Powershell-Convert-3835499d
# https://github.com/T13nn3s/Convert-LegacyExchangeDN-to-X500/blob/master/ConvertTo-X500.ps1