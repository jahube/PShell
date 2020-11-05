$path = "C:\DOWLOADPATH"
  $filename = "FILENAME.csv"
  $targetpath = "C:\"
  #####################
  $data = import-csv "$path\$filename"
  $dataset =   $data
  #####################
  $data.count
  # create domain array
  $domains = $dataset | group SenderDomain
  $domains = $domains | Sort-Object count -Descending
  $domains = $domains | select -first 300
  $domains = $newdom | select -first 300
  # create Date array
  $cals = ($dataset | group date).name
  $dateform = @()
  foreach ($cal in $cals) {
        $calendar = New-Object -TypeName PSObject       
        $calendar | Add-Member -MemberType NoteProperty -Name searchdate -Value $cal
        $calendar | Add-Member -MemberType NoteProperty -Name localdate -Value $(Get-Date $cal -Format "yyyy-MM-dd")
        $calendar | Add-Member -MemberType NoteProperty -Name propdate -Value $(Get-Date $cal -Format "yyyyMMdd")
        $calendar | Add-Member -MemberType NoteProperty -Name Weekday -Value $((Get-Date $cal).DayOfWeek)
  $dateform += $calendar
  }
  $dateform = $dateform | sort localdate
  #####################
  $dataset =   $data
  #####################
  $domains =   $dataset | group SenderDomain
  $domains =   $domains | Sort-Object count -Descending
  $domains = $domains | select -first 300
  $domains = $domains.name
  $collected=@()
  foreach ($D in $domains)
    {
        $items = $dataset | where { $_.SenderDomain -eq $D }
        $PHPitems = $items | where { $_.ConnectorName -eq "Inbound from PGP" }
        $PHPcount = 0 ;  foreach($Pit in $PHPitems) { $PHPcount += $Pit.MsgCount/1 }
        $NPitems = $items | where { $_.ConnectorName -ne "Inbound from PGP" }
        $NPcount = 0 ;  foreach($NPit in $NPitems) { $NPcount += $NPit.MsgCount/1 }
        $count = 0 ;  foreach($item in $items) { $count += $item.MsgCount/1 }
        $datum = New-Object -TypeName PSObject      
        $datum | Add-Member -MemberType NoteProperty -Name MsgCount -Value $count
        $datum | Add-Member -MemberType NoteProperty -Name SenderDomain -Value $D
        $datum | Add-Member -MemberType NoteProperty -Name ConnectorName -Value "Inbound from PGP" 
        $datum | Add-Member -MemberType NoteProperty -Name PGPconnector -Value $PHPcount
        $datum | Add-Member -MemberType NoteProperty -Name OtherConnector -Value $NPcount
      Foreach ($DDx in $dateform) {
        $daycnt = 0 ; $dayitems = $items | where { $_.date -eq $DDx.searchdate }
        $DMScount = 0 ;  foreach($dayit in $dayitems) { $DMScount += $dayit.MsgCount/1 }
        $datum | Add-Member -MemberType NoteProperty -Name $DDx.propdate -Value $DMScount
                                  }
        $collected += $datum 
    }

$filedate = $(Get-Date -Format "yyyyMMdd")
$targetfull = $($targetpath + $filedate + '-report-full.csv')
$target300 = $($targetpath + $filedate + '-report-300.csv')
$coll =  $collected | sort MsgCount -Descending
$coll |  export-csv $targetfull -Encoding UTF8
$coll300 =$coll | select -First 300
$coll300 |  export-csv $target300 -Encoding UTF8
$collected.count
$coll300 | ft