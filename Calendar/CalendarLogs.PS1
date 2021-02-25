# install-module exchangeonlinemanagement
# connect-exchangeonline -UserPrincipalName ADMIN

$user = "user@domain.com"
$startDays = "-14"
$endDays = "30"
$Subject = "" #Subject

$path = "C:\Temp"

   $start = (get-date).AddDays($startDays).ToShortDateString() ;
     $end = (get-date).AddDays($endDays).ToShortDateString() ;
$Calendar = Get-CalendarDiagnosticLog $user -StartDate $start -EndDate $end -WA silentlycontinue ;
   $Match = $Calendar.Where({($_.NormalizedSubject -match $Subject) -or ($_.NormalizedSubject -eq $Subject)})
     $Cal = $Match | sort-Object CleanGlobalObjectId -Unique ;

$count= $Cal.count ; $label = "Calendarlogs for [$user]"
  for ($C = 0; $C -lt $Cal.count; $C++) { 
       $S =" [Event Count] ($($C+1)/$count)  [Time]"
       $A = "$label [Subject] $($Cal[$C].NormalizedSubject) [Date] $($Cal[$C].LogDate)" ; 
      $ID = $Cal[$C].CleanGlobalObjectId
       
       Write-Progress -Activity $A -Status $S -PercentComplete (($C/$count)*100) -SecondsRemaining ($count-$C) ;

     $Out = Get-CalendarDiagnosticObjects -Identity $user -MeetingId $ID -StartDate $start -EndDate $end -WA silentlycontinue ;
    $DayN = (get-date $Cal[$C].LogDate).DayOfWeek ; 
 $Datestr = get-date $Cal[$C].LogDate -Format yyyy-MM-dd-HHmm ;
   $FileN =  $Cal[$C].CleanGlobalObjectId + '_' + $Cal[$C].NormalizedSubject + '.Csv' ; 
$FileName = $FileN.Split([IO.Path]::GetInvalidFileNameChars()) -join '_';IF(!(Test-Path $path)){mkdir $path}
     $Out | Export-csv $path\$Filename -NoTypeInformation }
