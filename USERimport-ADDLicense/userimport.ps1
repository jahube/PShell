$CsvPath = "$ENV:UserProfile\Documents\users.csv"

$import = Import-Csv $CsvPath -Encoding UTF8     # change to UTF7 if exported eg. from Outlook contacts

$users = Get-Msoluser -all

$ActSku = (Get-MsolAccountSku)

# list line by line
$E1 = ($ActSku | where { $_.AccountSkuId -match 'E1 string here' }[0]
$Business = ($ActSku | where { $_.AccountSkuId -match 'Business' }[0]
$E3 = ($ActSku | where { $_.AccountSkuId -match 'Enterprisestandard' }[0]
$E5 = ($ActSku | where { $_.AccountSkuId -match 'Enterprisepremium' })[0]

$ServiceDisableList =@("WHITEBOARD_PLAN2","FLOW_P1","MYANALYTICS_P2","KAIZALA_STANDALONE")
$ServiceDisable = New-MsolLicenseOptions -AccountSkuId $ActSku.AccountSkuId -DisabledPlans $ServiceDisableList

$ParamNew = @{ UserPrincipalName = $new.UserPrincipalName
DisplayName = $DisplayName
FirstName = $FirstName
LastName = $LastName 
erroraction = 'stop' }

$ParamDetail = @{ UserPrincipalName = $new.UserPrincipalName
DisplayName = $new.DisplayName
UsageLocation = $new.UsageLocation
LicenseAssignment = $license.AccountSkuId
LicenseOptions = $ServiceDisable
Department = $new.Department
MobilePhone = $new.MobilePhone
erroraction = 'stop' }

$addnew = @()
$detailsadd = @()
$failnew = @()
$faildetail = @()
$exists = @()

Foreach ($new in $import) {

$found=$users | ? {($($new.userprincipalname.ToString()) -in $($users.userprincipalname)) -or ($($new.displayname.ToString()) -in $($users.displayname)) }

if ($found) {  Write-host "`n [USER] $($found.displayname) - [UPN:] $($found.userprincipalname) already exists" -F yellow ; $exists += $new }

if (!($found)) { 

$displayname = $new.displayname
$firstname = $new.firstname
$lastname = $new.lastname
$userprincipalname = $new.userprincipalname
$splitname = $userprincipalname.Split('@')[0].Replace('.', ' ')
# output = First Last
$splitfirst = $splitname.Split(' ')[0] # FIRST.last@domain.com ; 
$splitfirst = $splitfirst.substring(0,1).toupper() + $splitfirst.substring(1).tolower()
$splitlast = $splitname.Split(' ')[1] # first.LAST@domain.com 
$splitlast = $splitlast.substring(0,1).toupper() + $splitlast.substring(1).tolower()
$splitname = "$($splitfirst + ' ' + $splitlast)"

if ($new.displayname) { $displayname = $new.displayname } else {$displayname = $splitname }
if ($new.firstname) { $firstname = $new.firstname } else { $firstname = $splitfirst }
if (!($firstname)) { $firstname = $displayname.Split(' ')[0] }
if ($new.lastname) { $lastname = $new.lastname } else { $lastname = $splitlast }
if (!($lastname)) { $lastname = $displayname.Split(' ')[1] }

Try { 

New-MsolUser @ParamNew ;

      Write-host "`n [USER] $($found.displayname) - [UPN:] $($found.userprincipalname) successfully created" -F green ; 

      $addnew += $new ;

    } catch { 

      Write-host "`n [USER] $($found.displayname) - [UPN:] $($found.userprincipalname) failled to ADD [ERROR:] $($error[0].exception.message)" -F yellow ; 

      $failnew += $new 
 
    }


 Try { 
 
 Switch ($($new.license))
{
    E1 {$license = $E1}
    Business {$license = $business}
    E3 {$license = $E3}
    E5 {$license = $E5}
}
if (!($license)) { $license = $ActSku[0] }
 
 Set-MsolUser @ParamDetail ; $detailsadd += $new ;

       Write-host "`n [USER] $($found.displayname) - [UPN:] $($found.userprincipalname) successfully added details" -F cyan ;           

     } catch { $faildetails  += $new ;

                Write-host "`n [USER] $($found.displayname) - [UPN:] $($found.userprincipalname) failled to ADD details - [ERROR:] $($error[0].exception.message)" ; 

     }

}

Write-host "`n$($addnew.count) users added - " -F green -NoNewline
Write-host "$($failnew.count)x failed to add user`n" -F yellow
Write-host "$($detailsadd.count) details added - " -F green -NoNewline
Write-host "$($faildetail.count)x failed add details`n" -F yellow
Write-host "$($exists.count) users already exist" -F cyan