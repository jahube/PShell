
         $NEW_RBAC = "Custom Role Assignment Policy"
             $Role = "MyBaseOptions"          # Parent to clone
          $NewRole = "MyBaseOptions_COPY2" #Name of the Child Clone
       $commandlet = "Set-MailboxJunkEmailConfiguration"
$Remove_Parameters = "TrustedSendersAndDomains", "ContactsTrusted", "TrustedListsOnly", "BlockedSendersAndDomains"

##################################################################################################################
#  EXO "clones" a Role under a Parent
#   (1) inherits parent RoleEntries
#   (2) modify RoleEntries under the inherited items
##################################################################################################################

New-ManagementRole -Name $NewRole -Description @(Get-ManagementRole $Role).Description -Parent $Role

Set-ManagementRoleEntry $("$NewRole" +"\" + "$commandlet") -Parameters $Remove_Parameters -RemoveParameter

##################################################################################################################

$RBAC = Get-RoleAssignmentPolicy | where { $_.IsDefault -eq $true };

$RBAC.AssignedRoles.RemoveAt($RBAC.AssignedRoles.IndexOf($Role)) 

New-RoleAssignmentPolicy -Name $NEW_RBAC -Description $RBAC.Description -Roles @($RBAC.AssignedRoles + $NewRole) 

##################################################################################################################
# assign Custom Role Assignment Policy #

$MBXs = Get-Mailbox -ResultSize unlimited | select Use*e,pri*s,Disp*e,Ex*id | Out-GridView -T "Select Users to modify" -PassThru ; $MBXs

Foreach ($MBX in $MBXs) { Set-Mailbox $MBX.ExternalDirectoryObjectId -RoleAssignmentPolicy $NEW_RBAC }