
$LOGS = Get-AzureADAuditDirectoryLogs

[Array]$paths = $()

$Members1 = $LOGS | get-member | where { $_.MemberType -eq "Property" }
$Strings1 = ($Members1 | where { $_.Definition -match "string" -or $_.Definition -match "Date" }).name
 $Arrays1 = ($Members1 | where { $_.Definition -notmatch "string" -and $_.Definition -notmatch "Date" } ).name

foreach ($String1 in $Strings1) {

$paths += $String1

}

foreach ($Array1 in $Arrays1) {

$Members2 = ""
$Members2 = $LOGS.$Array1 | get-member | where { $_.MemberType -eq "Property" }

IF ($Members2) { 

$Strings2 = ($Members2 | where { $_.Definition -match "string" -or $_.Definition -match "Date" }).name
 $Arrays2 = ($Members2 | where { $_.Definition -notmatch "string" -and $_.Definition -notmatch "Date" } ).name

}

foreach ($String2 in $Strings2) {

$paths += [String]$("$Array1.$String2")

}

foreach ($Array2 in $Arrays2) {

$Members3 = ""
$Members3 = $LOGS.$Array1.$Array2 | get-member | where { $_.MemberType -eq "Property" }

IF ($Members3) { 

$Strings3 = ($Members3 | where { $_.Definition -match "string" -or $_.Definition -match "Date" }).name
 $Arrays3 = ($Members3 | where { $_.Definition -notmatch "string" -and $_.Definition -notmatch "Date" } ).name

}


foreach ($String3 in $Strings3) {

$paths += [String]$("$Array1.$Array2.$String3")

}

foreach ($Array3 in $Arrays3) {

$Members4 = ""
$Members4 = $LOGS.$Array1.$Array2 | get-member | where { $_.MemberType -eq "Property" }

IF ($Members4) { 

$Strings4 = ($Members4 | where { $_.Definition -match "string" -or $_.Definition -match "Date" }).name
 $Arrays4 = ($Members4 | where { $_.Definition -notmatch "string" -and $_.Definition -notmatch "Date" } ).name

}


foreach ($String4 in $Strings4) {

$paths += [String]$("$Array1.$Array2.$Array3.$String4")

}

     }

   }

}

##############################################################################
##############################################################################

$OUT = @()

Foreach ($line in $LOGS) {

        $data = New-Object -TypeName PSCustomObject

Foreach ($path in $paths) {

$items = try { IEX `$line.$path -erroraction "STOP" } catch { }

IF ($items) { $itemstring = $items -join '; ' } ELSE { $itemstring = " " }

$data | Add-Member -MemberType NoteProperty -Name $path -Value $itemstring

}

$OUT += $data

}

$OUT | Export-Csv "C:\securitylogs.csv" -Force

$OUT | FT -autosize


##############################################################################

function propByPath { param($obj, $propPath) foreach ($prop in $propPath.Split('.')) { $obj = $obj.$prop }; $obj }
# https://stackoverflow.com/questions/51863251/access-psobject-property-indirectly-with-variable



$OUT = @()

Foreach ($line in $LOGS) {

        $data = New-Object -TypeName PSCustomObject

Foreach ($path in $paths) {

$items = try { propByPath $line $path -erroraction "STOP" } catch { }

IF ($items) { $itemstring = $items -join '; ' } ELSE { $itemstring = " " }

$data | Add-Member -MemberType NoteProperty -Name $path -Value $itemstring

}

$OUT += $data

}

$OUT | Export-Csv "C:\securitylogs2.csv" -Force

$OUT | FT -autosize