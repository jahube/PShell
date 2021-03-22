
$user = "user@domain.com"

IF(!@(Get-PSSession | where { $_.State -ne "broken" } )) {
IF(!@(Get-InstalledModule ExchangeOnlineManagement -ErrorAction SilentlyContinue)) { install-module exchangeonlinemanagement -Scope CurrentUser }

IF(!@($Credentials)) {$Credentials = Get-credential } ; IF(!@($ADMIN)) {$ADMIN = $Credentials.UserName }
Try { Connect-ExchangeOnline -Credential $Credentials -EA stop } catch { Connect-ExchangeOnline -UserPrincipalName $ADMIN } }


  Try {$MBX = get-mailbox $user -EA stop } 
catch { $user = read-host "enter user to check" ; $MBX = get-mailbox $user }

[array]$groups = Get-UnifiedGroup -ResultSize unlimited

$OwnerOF = @()
$MemberOF = @()
foreach ($G in $groups) { 

$owner = Get-UnifiedGroupLinks $G.name -LinkType owner
$member = Get-UnifiedGroupLinks $G.name -LinkType member

foreach ($O in $owner) 
{ 
IF ($O.name -eq $MBX.name) { $OwnerOF += $G }
Elseif ($O.PrimarySmtpAddress -eq $MBX.PrimarySmtpAddress) { $OwnerOF += $G }
Elseif ($O.WindowsLiveID -eq $MBX.WindowsLiveID) { $OwnerOF += $G }
}

foreach ($M in $member) 
{ 
IF ($M.name -eq $MBX.name) { $MemberOF += $G }
Elseif ($M.PrimarySmtpAddress -eq $MBX.PrimarySmtpAddress) { $MemberOF += $G }
Elseif ($M.WindowsLiveID -eq $MBX.WindowsLiveID) { $MemberOF += $G }
}
}
$OwnerOF | Export-csv "C:\$($MBX.name)_OwnerOF.CSV" -NoTypeInformation
$MemberOF | Export-csv "C:\$($MBX.name)_MemberOF.CSV" -NoTypeInformation