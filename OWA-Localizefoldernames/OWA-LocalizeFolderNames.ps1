##################################
# for all mailboxes progress bar #
##################################
$Language  = "DE-DE" # Examples: "EN-US" "EN-GB" "DE-CH" "FR-FR" "DE-DE" "FR-BE" "FR-TN"
##################################
$culture = New-Object system.globalization.cultureinfo($Language)
  $param = @{    Identity = $MBX[$M] 
                 Language = $Language
               TimeFormat = $culture.DateTimeFormat.ShortTimePattern
               DateFormat = $culture.DateTimeFormat.ShortDatePattern
                 TimeZone = "W. Europe Standard Time"
LocalizeDefaultFolderName = $true
                  Confirm = $false 
              ErrorAction = 'Stop' }
                    $mbxs = get-mailbox -ResultSize unlimited; $count= $MBXs.count
[System.Collections.ArrayList]$MBX = $mbxs.userprincipalname
$label="[$($param.Language) $($culture.DisplayName)] Time[$($param.TimeFormat)] Date[$($param.DateFormat)]"
for ($M = 0; $M -lt $MBX.count; $M++) { $S =" [MBX] ($($M+1)/$count)  [Time]"
$A = "Changing Folder language $label  [Mailbox Count] ($($M+1)/$count) [Mailbox] $($MBX[$M])"
Write-Progress -Activity $A -Status $S -PercentComplete (($M/$count)*100) -SecondsRemaining ($count-$M) ;
Try { Set-MailboxRegionalConfiguration @param } catch { Write-Host $Error[0].Exception.Message -F Yellow } }

####################
# for ONE mailboxe #
####################
$Language  = "DE-DE" # Examples: "EN-US" "EN-GB" "DE-CH" "FR-FR" "DE-DE" "FR-BE" "FR-TN"
  $Mailbox = 'user@domain.com'
##################################
$culture = New-Object system.globalization.cultureinfo($Language)
  $param = @{    Identity = $Mailbox
                 Language = $Language
               TimeFormat = $culture.DateTimeFormat.ShortTimePattern
               DateFormat = $culture.DateTimeFormat.ShortDatePattern
                 TimeZone = "W. Europe Standard Time"
LocalizeDefaultFolderName = $true
                  Confirm = $false 
              ErrorAction = 'Stop' }
Try { Set-MailboxRegionalConfiguration @param } catch { $Error[0] | fl }