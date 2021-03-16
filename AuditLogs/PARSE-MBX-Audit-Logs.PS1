$path = "C:\Users\NAME\Downloads\mailboxlogs"
$file = "mailboxlogs.xml"
$data = Import-Clixml $path\$file
$data | get-member
$properties = $data | get-member | where { $_.Membertype -eq "Property"}
$data | get-member | select name

$data | select-object operation,clientprocessname,clientinfostring,ClientVersion -Unique
($data | group operation,clientprocessname).name
$softdelete = $data | where {$_.operation -eq "softdelete" }
$harddelete = $data | where {$_.operation -eq "harddelete" }

($softdelete | group operation,clientprocessname,clientinfostring,ClientVersion).Name
$harddelete | group operation,clientprocessname,clientinfostring,lastaccessed,clientip,ClientVersion | select count,Name > c:\harddelete.txt

$softdelete | group operation,clientprocessname,clientinfostring,lastaccessed,clientip,ClientVersion | select count,Name > c:\softdelete.txt