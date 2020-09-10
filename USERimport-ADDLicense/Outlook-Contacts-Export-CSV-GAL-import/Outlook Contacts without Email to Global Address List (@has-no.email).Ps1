$cred = Import-Clixml $ENV:UserProfile\Documents\MyCredential.xml

Connect-MsolService -Credential $cred

$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $cred -Authentication Basic -AllowRedirection

Import-PSSession $Session -DisableNameChecking


#############################
### create dummy emails #####
#############################

$objs =@();
$replacements = "[^a-zA-Z0-9]." # anything that's _not_ a-z or underscore
$result = $original -replace $replacements, '.'
$output = Import-Csv $ENV:UserProfile\Desktop\kontakteohneemail.csv -Encoding UTF7 | ForEach {

$Email=$_.Anzeigename
$Email=$Email -replace 'ä', 'ae'
$Email=$Email -replace 'ö', 'oe'
$Email=$Email -replace 'ü', 'ue'
$Email=$Email -replace 'Ä', 'Ae'
$Email=$Email -replace 'Ü', 'Ue'
$Email=$Email -replace 'Ö', 'Oe'
$Email=$Email -replace 'ß', 'ss'

$Email=$Email -replace $replacements, '.'
$Email= [String]::Concat($Email, '@hat-keine.email')

$Object = New-Object PSObject -Property @{           
        Anzeigename=$_.Anzeigename
        Vorname=$_.Vorname
        Nachname=$_.Nachname
        Mobiltelefon=$_.Mobiltelefon
        Email=$Email
        Telefon=$_.Telefon
        Fax=$_.Fax

    }  
    $objs += $Object;
}
$objs
$objs | Export-CSv $ENV:UserProfile\Desktop\kontaktefixed.csv -Encoding UTF8 -NoTypeInformation


########################
### import contacts ####
########################


$kontakte =@();
$kontakte = Import-Csv $ENV:UserProfile\Desktop\kontaktefixed.csv  -Encoding UTF8
$kontakte| %{ New-MailContact -Name $_.Anzeigename -DisplayName $_.Anzeigename -ExternalEmailAddress $_.Email -FirstName $_.Vorname -LastName $_.Nachname }


###################################
### filter + add phone numbers ####
###################################

$verteiler =@();
$verteiler = Import-Csv $ENV:UserProfile\Desktop\kontaktefixed.csv -Encoding UTF8 | ForEach {


$Mobiltelefon = $_.Mobiltelefon
 $Mobiltelefon = $Mobiltelefon -Replace "(^\+49(\s)?0)|(^0)", "+49"
 $Mobiltelefon = $Mobiltelefon -Replace "^\(0\)", "+49-"
 $Mobiltelefon = $Mobiltelefon -Replace "^\(", "+49-"
 $Mobiltelefon = $Mobiltelefon -Replace "^0", "+49-"
 $Mobiltelefon = $Mobiltelefon -Replace "(\s)", ""
 $Mobiltelefon = $Mobiltelefon -Replace "\)", "-"
 $Mobiltelefon = $Mobiltelefon -Replace "\.", "-"
 $Mobiltelefon = $Mobiltelefon -Replace "\?", ""
 $Mobiltelefon = $Mobiltelefon -Replace "^\+49\-0", "+49-"
 $Mobiltelefon = $Mobiltelefon -Replace "^15", "+49-15"
 $Mobiltelefon = $Mobiltelefon -Replace "^16", "+49-16"
 $Mobiltelefon = $Mobiltelefon -Replace "^17", "+49-17"
 $Mobiltelefon = $Mobiltelefon -Replace "^3", "+49-3"

$Telefon = $_.Telefon
 $Telefon = $Telefon -Replace "(^\+49(\s)?0)|(^0)", "+49-"
 $Telefon = $Telefon -Replace "^\(0\)", "+49-"
 $Telefon = $Telefon -Replace "^\(", "+49-"
 $Telefon = $Telefon -Replace "^0", "+49-"
 $Telefon = $Telefon -Replace "(\s)", ""  
 $Telefon = $Telefon -Replace "\?", ""  
 $Telefon = $Telefon -Replace "\)", "-"  
 $Telefon = $Telefon -Replace "\.", "-"  
 $Telefon = $Telefon -Replace "^\+49\-0", "+49-"
 $Telefon = $Telefon -Replace "^15", "+49-15"
 $Telefon = $Telefon -Replace "^16", "+49-16"
 $Telefon = $Telefon -Replace "^17", "+49-17"
 $Telefon = $Telefon -Replace "^17", "+49-17"
 $Telefon = $Telefon -Replace "^3", "+49-3"

$Fax = $_.Fax
 $Fax = $Fax -Replace "(^\+49(\s)?0)|(^0)", "+49-"
 $Fax = $Fax -Replace "^\(0\)", "+49-"
 $Fax = $Fax -Replace "^\(", "+49-"
 $Fax = $Fax -Replace "^0", "+49-"
 $Fax = $Fax -Replace "(\s)", ""
 $Fax = $Fax -Replace "\)", "-"
 $Fax = $Fax -Replace "\.", "-"
 $Fax = $Fax -Replace "\?", ""
 $Fax = $Fax -Replace "^\+49\-0", "+49-"
 $Fax = $Fax -Replace "^15", "+49-15"
 $Fax = $Fax -Replace "^16", "+49-16"
 $Fax = $Fax -Replace "^17", "+49-17"
 $Fax = $Fax -Replace "^3", "+49-3"

$Email = $_.Email

if($Mobiltelefon -ne '')
    {
Set-Contact -Identity $Email -MobilePhone $Mobiltelefon
Write-Host "Added Mobile Number "$Mobiltelefon" for "$Email;
    }

if($Telefon -ne '')
    {
Set-Contact -Identity $Email -Office $Telefon -HomePhone $Telefon
Write-Host "Added Phone Number "$Telefon" for "$Email;
    }
if($Telefon -eq '' -and $Mobiltelefon -ne '')
    {
Set-Contact -Identity $Email -Office $Mobiltelefon -HomePhone $Mobiltelefon
Write-Host "Added Mobile Number "$Mobiltelefon" instead of missing Phone Number for "$Email;
    }

if($Fax -ne '')
    {
Set-Contact -Identity $Email -Fax $Fax
Write-Host "Added Fax Number "$Fax" for "$Email;
    }
}