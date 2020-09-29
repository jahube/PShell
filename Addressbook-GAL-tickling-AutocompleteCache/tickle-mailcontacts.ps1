$MailContacts = get-MailContact -resultsize unlimited
Write-Host
Write-Host “Mail Contacts Found:” $count
foreach($mailcontact in $mailcontacts){
$i++
Set-MailContact $mailcontact.alias -SimpleDisplayName $mailcontact.SimpleDisplayName -WarningAction silentlyContinue
Write-Progress -Activity “Tickling Mail Contact [$count]…” -Status $i
}