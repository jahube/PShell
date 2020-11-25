# OWA-AutoCompleteCache

$Configs = "Configuration\IPM.Configuration.Relevance.SasPeopleMetadataModel"
$Configs += "Configuration\IPM.Configuration.Relevance.SasPeopleIndexModel"
$Configs += "IPM.Configuration.Relevance.SasInstantIndexModelItem"
$Configs += "Configuration\IPM.Configuration.AutoComplete"
$Configs += "Configuration\IPM.Configuration.OWA.AutocompleteCache"

$mbxs = get-mailbox -ResultSize unlimited; $count= $MBXs.count
[System.Collections.ArrayList]$MBX = $mbxs.userprincipalname
for ($M = 0; $M -lt $MBX.count; $M++) { $S =" [MBX] ($($M+1)/$count)  [Time]"
$A = "Clearing OWA Autocomplete Cache [Mailbox Count] ($($M+1)/$count) [Mailbox] $($MBX[$M])"
Write-Progress -Activity $A -Status $S -PercentComplete (($M/$count)*100) -SecondsRemaining $($count-$M) ;

Foreach ($C in $Configs) {
Try { Remove-MailboxUserConfiguration -Mailbox $MBX[$M] -Identity $c -Confirm:$false 
} catch { Write-Host $Error[0].Exception.Message -F Yellow } } }


# Outlook Offline Addressbook - for reference
# delete subfolders when Outlook is closed
# the OAB will be immediately downloaded again once Outlook is started
# Filemanager OR  Search beside Start menu
# %LocalAppData%\Microsoft\Outlook\Offline Address Books\
# %LocalAppData%\Microsoft\Outlook\RoamCache\