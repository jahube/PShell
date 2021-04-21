# install-module exchangeonlinemanagement
# connect-exchangeonline -UserPrincipalName ADMIN

     $user = "user@domain.com"
$startDays = "-14"     # [-] days in past
  $endDays = "30"      # [+] days in future
        $S = ""        # Subject   "" -> skip filter

$path = "C:\Temp"

############################################################################################################
$st = (get-date).AddDays($startDays).tostring(“MM/dd/yyyy”) 
$ed = (get-date).AddDays($endDays).tostring(“MM/dd/yyyy”)
$Cld = Get-CalendarDiagnosticLog $user -StartDate $st -EndDate $ed -WA silentlycontinue ;
$Cal=$Cld.Where({$_.NormalizedSubject -match $S -or $_.NormalizedSubject -eq $S})|sort-Object CleanGlobalObjectId -Unique;
$count= $Cal.count ; $label = "Calendarlogs for [$user]" ;  for ($C = 0; $C -lt $Cal.count; $C++) { 
$A = "$label [Subject] $($Cal[$C].NormalizedSubject) [Date] $($Cal[$C].LogDate)" ; 
$ID = $Cal[$C].CleanGlobalObjectId ; $S =" [Event Count] ($($C+1)/$count)  [Time]"
Write-Progress -Activity $A -Status $S -PercentComplete (($C/$count)*100) -SecondsRemaining ($count-$C) ;
$Out = Get-CalendarDiagnosticObjects -Identity $user -MeetingId $ID -StartDate $st -EndDate $ed -WA silentlycontinue ;
$DayN = (get-date $Cal[$C].LogDate).DayOfWeek ;  $Datestr = get-date $Cal[$C].LogDate -Format yyyy-MM-dd-HHmm ;
[string]$FileN =  $Cal[$C].CleanGlobalObjectId + '_' + $DayN + '_' + $Datestr + '-' + $Cal[$C].NormalizedSubject 
[string]$FileName = $FileN.Split([IO.Path]::GetInvalidFileNameChars()) -join '_' ;[int]$Lgt=(240 - $path.Length)
if ($FileName.length -gt $Lgt) { $File = $FileName.substring(0, $Lgt) + '.Csv' } else { $File = $FileName + '.Csv' } ;
IF(!(Test-Path $path)){mkdir $path} ; $Out | Export-csv $path\$File -NoTypeInformation -force}
############################################################################################################ 
