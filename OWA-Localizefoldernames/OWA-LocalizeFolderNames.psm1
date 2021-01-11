Param(
         [Parameter(Mandatory = $true)]
         [string]$Language, # $Language  = "DE-DE" # Examples: "EN-US" "EN-GB" "DE-CH" "FR-FR" "DE-DE" "FR-BE" "FR-TN"
         [string]$TimeZone = "W. Europe Standard Time",
         [string]$admin,
          [array]$identity,
                 $credential,
         [switch]$All
    )


                 $culture = New-Object system.globalization.cultureinfo($Language)
                 $param = @{    
                 Language = $Language
               TimeFormat = $culture.DateTimeFormat.ShortTimePattern
               DateFormat = $culture.DateTimeFormat.ShortDatePattern
                 TimeZone = $TimeZone                
LocalizeDefaultFolderName = $true
                  Confirm = $false 
              ErrorAction = 'Stop' }

Function Remote-SetMBXlanguage {
Invoke-Command -Session $Global:session -ArgumentList $param,$label,$MBX -ScriptBlock { Set-MBXlanguage } # -AsJob
                               }
Function Check-EXOV2 { 

if (!(get-module ExchangeOnlineManagement)) { 
Try { Install-Module ExchangeOnlineManagement -Scope CurrentUser -Confirm:$false -EA stop } catch { Write-host $Error[0].Exception.Message -F yellow}
                                            }
                     }

Function Connect-EXOV2 {
if (!($admin)) {$admin = read-host -Prompt "Enter Global Admin [Admin@domain.com]" } else { $Global:Admin = $admin }
#credential
if (!($credential)) {$Global:credential = Get-Credential $admin} else { $Global:credential = $credential }

Get-PSSession | Remove-PSSession ; start-sleep 15 ;
Try{ Connect-ExchangeOnline -Credential $Global:credential -EA stop } catch { Connect-ExchangeOnline -UserPrincipalName $Global:Admin }
$Global:session = Get-PSSession
                       }

Function Get-MBXusers {

$session = Get-PSSession -InstanceId (Get-OrganizationConfig).RunspaceId.Guid

If ($identity -and !($All)) {

$command = @'
foreach ($Mailbx in $identity) { get-mailbox -identity $Mailbx -EA 'silentlycontinue' }
'@

$myscriptblock = [scriptblock]::Create("$command")

$mbxs =  Invoke-Command -ArgumentList $identity -Session $session -ScriptBlock $myscriptblock }

If (!($identity) -or $All) { 

$command = @'
get-mailbox -ResultSize unlimited -EA 'silentlycontinue'
'@

$myscriptblock = [scriptblock]::Create("$command")

$mbxs = Invoke-Command -Session $session -ScriptBlock $myscriptblock  }

[System.Collections.ArrayList]$Global:MBX = $mbxs.userprincipalname  }

Function Set-MBXlanguage {  
[System.Collections.ArrayList]$MBX = $Global:MBX  
$count= $MBX.count
$label = "[$($param.Language) $($culture.DisplayName)] Time[$($param.TimeFormat)] Date[$($param.DateFormat)]"
for ($M = 0; $M -lt $MBX.count; $M++) { $S =" [MBX] ($($M+1)/$count)  [Time]"
$A = "Changing Folder language $label  [Mailbox Count] ($($M+1)/$count) [Mailbox] $($MBX[$M])"
Write-Progress -Activity $A -Status $S -PercentComplete (($M/$count)*100) -SecondsRemaining ($count-$M) ;
Try { Set-MailboxRegionalConfiguration -Identity $MBX[$M] @param } catch { $Global:breakout = $M ; Write-Host $Error[0].Exception.Message -F Yellow } 
                                      }
                         }


Function Set-Mailboxlanguage {
Check-EXOV2
Connect-EXOV2
Get-MBXusers
Set-MBXlanguage           } 
