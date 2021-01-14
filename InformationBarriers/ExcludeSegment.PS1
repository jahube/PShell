Get-Organizationsegment | FT

$REMOVE = "Segment to remove"

$assignedpolicy = Get-InformationBarrierPolicy | where { $_.AssignedSegment -eq $REMOVE }

$allowedpolicy = Get-InformationBarrierPolicy | where { $REMOVE -in $_.SegmentsAllowed }

$blockedpolicy = Get-InformationBarrierPolicy | where { $REMOVE -in $_.SegmentsBlocked }

#remove
Foreach ($Policy in $assignedpolicy) {
set-InformationBarrierPolicy -Identity $Policy.guid -State inactive
remove-InformationBarrierPolicy -Identity $Policy.guid }

#update allowed
Foreach ($Policy in $allowedpolicy) {
[System.Collections.ArrayList]$Temp = $Policy.SegmentsAllowed
$Temp.Removeat($TMP.indexof($REMOVE)) ; $Allow = $Temp.ToArray() ; $Block = $Policy.SegmentsBlocked ;
 try { set-InformationBarrierPolicy -Identity $Policy.guid -SegmentsAllowed $Allow -EA Stop } catch {
set-InformationBarrierPolicy -Identity $Policy.guid -SegmentsAllowed $Allow -SegmentsBlocked $Block }

#update blocked
Foreach ($Policy in $blockedpolicy) {
[System.Collections.ArrayList]$Temp = $Policy.SegmentsBlocked
$Temp.Removeat($TMP.indexof($REMOVE)) ; $Block = $Temp.ToArray() ; $Allow = $Policy.SegmentsAllowed ;
 try { set-InformationBarrierPolicy -Identity $Policy.guid -SegmentsBlocked $Block -EA Stop } catch {
set-InformationBarrierPolicy -Identity $Policy.guid -SegmentsAllowed $Allow -SegmentsBlocked $Block }