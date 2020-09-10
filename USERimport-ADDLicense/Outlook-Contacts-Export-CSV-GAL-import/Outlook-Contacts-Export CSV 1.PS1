$file ="$ENV:UserProfile\Desktop\kontakteemail.csv"

$objs =@();
$verteiler = Import-Csv $file -Encoding UTF8
# $verteiler = Import-Csv $file -Encoding UTF7

$verteiler | %{ New-MailContact -Name $_.Anzeigename  -DisplayName $_.Anzeigename -ExternalEmailAddress $_.Email -FirstName $_.Vorname -LastName $_.Nachname }

$verteiler | %{ Remove-MailContact -Identity $_.Email -Confirm:$false }

$objs =@();
$output = Import-Csv $ENV:Onedrive\3287kontakteneu.CSV -Encoding UTF7 | ForEach {
if($_.Vorname  -ne '' -and $_.Nachname -ne '')
    {
        $Anzeigename=[String]::Concat($_.Vorname, ' ', $_.Nachname)
    }

  if($_.Vorname  -eq '' -or $_.Nachname -eq '')
    {
        $Anzeigename=[String]::Concat($_.Vorname, $_.Nachname)
    }

if($_.Vorname  -eq '' -and $_.Nachname -eq '')
    { $Anzeigename=$_."E-Mail-Adresse" }
if($_.Vorname  -eq '' -and $_.Nachname -eq '' -and $_."E-Mail-Adresse" -eq '')
     { $Anzeigename=[String]::Concat($_."Telefon geschäftlich", $_.Mobiltelefon) }

$Object = New-Object PSObject -Property @{           
        Anzeigename=$Anzeigename
        Vorname=$_.Vorname
        Nachname=$_.Nachname
        Mobiltelefon=$_.Mobiltelefon
        Email=$_."E-Mail-Adresse"
        Telefon=$_."Telefon geschäftlich"
        Fax=$_."Fax geschäftlich"

    }  
    $objs += $Object;
}
$objs
$objs | Export-CSv $ENV:UserProfile\Documents\kontakteneu.csv -Encoding UTF8 -NoTypeInformation
$objs | Where-Object {$_.Email  -ne '' -and $_.Vorname  -ne ''  -and $_.Nachname  -ne '' } | Export-CSv $ENV:UserProfile\Documents\kontakteemail.csv -Encoding UTF8 -NoTypeInformation
$objs | Where-Object {$_.Email  -eq '' } | Export-CSv $ENV:UserProfile\Documents\kontakteohneemail.csv -Encoding UTF8 -NoTypeInformation