$path2 = "C:\test.html"

$variable = [pscustomobject] @{
"Group Name" = "Authenticated Users"
"Members" = "User1", "User2", "User3"
}

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
'@

foreach($VarItem in $variable) {
 $body += $("`n" + '<table style="width:100%">')
$Body += $("`n" + '<tr><th>Group Name</th><th colspan="' + $(($VarItem.Members).count) + '">Members</th></tr>' +"`n<tr>")
$body +=  "<td>$($VarItem.'Group Name')</td>"
 for ($P = 0; $P -lt @($VarItem.Members).count; $P++) {

 $body +=  "`n<td>$($VarItem.Members[$P])</td>"

   }
   $body +=  "`n</tr>"
   $body += "</table>"
}
     
$body += "`n`n`n<footer> The message was sent on: $(get-date)</footer>
</body>
</html>" ;

$body | Out-File $path2 -Forcev