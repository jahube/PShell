$path = "C:\test.html"
$variable = [pscustomobject] @{
"Group Name" = "Authenticated Users"
"Members" = "User1", "User2", "User3"
}
#$property = @("Group Name","Members")
$property = @($variable | get-member | where {$_.MemberType -eq "NoteProperty"}).name
##########################################################

$Body = @'
<!DOCTYPE html>
<html>
<head>
<style>
table, th, td {
  border: 1px solid black;
  border-collapse: collapse;
}
th, td {
  padding: 5px;
  text-align: left;    
}
</style>
</head>
<body>
<p></p>
'@
$body += "`n" + '<table style="width:100%">'
$Body += "`n<tr><th>$($property[0])</th><th>$($property[1])</th></tr>"
foreach($VarItem in $variable) {

$body +=  $("`n<tr>" + '<td rowspan="' + $(($VarItem.$($property[1])).count + "1") + '">' + $VarItem.$($property[0]) + '</td>')
 for ($P = 0; $P -lt $($VarItem.$($property[1])).count; $P++) {

 $body +=  "`n<tr><td>$(($VarItem.$($property[1]))[$P])</td></tr>"

   }
   $body +=  "`n</tr>"
   $body += "</table>"
}
     
$body += "`n`n`n<p></p>`n`n<footer> The message was sent on: $(get-date)</footer>
</body>
</html>" ;

$body | Out-File $path -Force