# Retention Folder TAGS Report ("Personal Tags")

$path = "C:\temp"                 # <-- Change Folder

$users = "user1","user2","user3"  # <-- Change users

$mbxs = $users | % { get-mailbox -Identity $_ }

# $mbxs = get-mailbox -ResultSize unlimited; # # <-- OR - ALL users >> remove the '#' <<

$count= $MBXs.count
[System.Collections.ArrayList]$MBX = @($mbxs.userprincipalname)
$collected=@()
for ($M = 0; $M -lt $MBX.count; $M++) {​ $S =" [MBX] ($($M+1)/$count)  [Time]"
$A = "collecting archive tag information [Mailbox Count] ($($M+1)/$count) [Mailbox] $($MBX[$M])"
Write-Progress -Activity $A -Status $S -PercentComplete (($M/$count)*100) -SecondsRemaining $($count-$M) ;
Try {​ $U = get-mailboxfolderstatistics $MBX[$M] -EA stop }​ catch {​ Write-Host $Error[0].Exception.Message -F Yellow }​
$r = @()
If ($U) {​ $R = $U | ? {​ $_.archivepolicy -ne $null }​ | select name,archivepolicy
   If ($R) {​
Foreach ($item in $R) {​ 
        $ret = New-Object -TypeName PSObject
        $ret | Add-Member -MemberType NoteProperty -Name user -Value $MBX[$M]
        $ret | Add-Member -MemberType NoteProperty -Name folder -Value $item.name
        $ret | Add-Member -MemberType NoteProperty -Name policy -Value $item.archivepolicy
        $collected += $ret
                      }​
           }​ else {​
        $ret = New-Object -TypeName PSObject
        $ret | Add-Member -MemberType NoteProperty -Name user -Value $MBX[$M]
        $ret | Add-Member -MemberType NoteProperty -Name folder -Value NONE
        $ret | Add-Member -MemberType NoteProperty -Name policy -Value NONE
        $collected += $ret
               }​
        }​
}​
$collected | export-csv "$path\retentionfoldertags.csv"
$collected | ft > "$path\retentionfoldertags.txt"
