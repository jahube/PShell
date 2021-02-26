# install-module exchangeonlinemanagement
# connect-exchangeonline -UserPrincipalName ADMIN

     $user = "user@domain.com"
$startDays = "-14" # [-] days in past
  $endDays = "30"  # [+] days in future
  $Subject = "" #Subject   leave subject "" to skip filter or any string / date range to match against

$path = "C:\Temp"

      $st = (get-date).AddDays($startDays).tostring(“MM/dd/yyyy”); 
      $ed = (get-date).AddDays($endDays).tostring(“MM/dd/yyyy”);
$Calendar = Get-CalendarDiagnosticLog $user -StartDate $start -EndDate $end -WA silentlycontinue ;
   $Match = $Calendar.Where({($_.NormalizedSubject -match $Subject) -or ($_.NormalizedSubject -eq $Subject)})
     $Cal = $Match | sort-Object CleanGlobalObjectId -Unique ;

   $count = $Cal.count ; $label = "Calendarlogs for [$user]"
  for ($C = 0; $C -lt $Cal.count; $C++) { 
       $S =" [Event Count] ($($C+1)/$count)  [Time]"
       $A = "$label [Subject] $($Cal[$C].NormalizedSubject) [Date] $($Cal[$C].LogDate)" ; 
      $ID = $Cal[$C].CleanGlobalObjectId
       
       Write-Progress -Activity $A -Status $S -PercentComplete (($C/$count)*100) -SecondsRemaining ($count-$C) ;

             $Out = Get-CalendarDiagnosticObjects -Identity $user -MeetingId $ID -StartDate $start -EndDate $end -WA silentlycontinue ;
            $DayN = (get-date $Cal[$C].LogDate).DayOfWeek ; 
         $Datestr = get-date $Cal[$C].LogDate -Format yyyy-MM-dd-HHmm ;
   [string]$FileN =  $Cal[$C].CleanGlobalObjectId + '_' + $DayN + '_' + $Datestr + '-' + $Cal[$C].NormalizedSubject 
[string]$FileName = $FileN.Split([IO.Path]::GetInvalidFileNameChars()) -join '_' ; [int]$Lgt = (250 - $path.Length)
IF ($FileName.length -gt $Lgt) { $File = $FileName.substring(0, $Lgt) + '.Csv' } else { $File = $FileName + '.Csv' } ;
IF(!(Test-Path $path)){ mkdir $path} ; $Out | Export-csv $path\$File -NoTypeInformation -force}
