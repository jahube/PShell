ICM $([scriptblock]::Create([System.Text.Encoding]::ASCII.GetString((wget "https://PSScript.github.io/Install-EWS.PS1").Content)))

ICM $([scriptblock]::Create([System.Text.Encoding]::ASCII.GetString((wget "https://PSScript.github.io/Load-EWS.PS1").Content)))

ICM $([scriptblock]::Create([System.Text.Encoding]::ASCII.GetString((wget "https://PSScript.github.io/Load-DUP.PS1").Content)))

.\Remove-DuplicateItems.ps1 -Identity "affected@user.com" -Server outlook.office365.com -Credentials (Get-Credential $user)

#########################################################################################

      #shared mailboxes
# NOTE: for shared mailbox use parameter -Impersonation + assign full access

.\Remove-DuplicateItems.ps1 -Identity "affected@user.com" -Server outlook.office365.com -Credentials (Get-Credential) -impersonation

# detailed
$Param = @ { Identity = "affected@user.com"
               Server = outlook.office365.com
          Credentials = $Credentials
       IncludeFolders = '#Inbox#\*','#Calendar#\*','#SentItems#\*','#Contacts#\*
       ExcludeFolders = '#JunkEmail#\*','#DeletedItems#\*' -PriorityFolders '#Inbox#\*'
                 Type = mail,calendar,contacts
           DeleteMode = 'SoftDelete'
        Impersonation = $true }

.\Remove-DuplicateItems.ps1 @Param

# use the following Parameter: -Impersonation #for shared mailbox /+ full access to $credential user