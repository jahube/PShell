###########################################################################################################
# Change Variables
[String]$NEW_RBAC = "Custom Role Assignment Policy" # Custom Name
  [String]$Suffix = "_Copy" # ( = "Role_Name + "_Suffix")
   $AssignedRoles = (Get-RoleAssignmentPolicy | where { $_.IsDefault -eq $true }).AssignedRoles
$DefaultRoleentry = Get-ManagementRoleEntry *\* | where {  $_.Role -in $AssignedRoles }

###########################################################################################################
## Option 1 #### Filter SET- / NEW- / Remove- #############################################################

$Commandlist = $DefaultRoleentry | where { $_.Name -like "Set*" -or $_.Name -like "New*" -or $_.Name -like "Remove*" }

###########################################################################################################
## Option 2 ############# Filter by Commandlet ############################################################

$Commandlist = $DefaultRoleentry | where { $_.Name -match "Set-MailboxJunkEmailConfiguration" }

###########################################################################################################
############ Select EXACT Commandlets AND Parameter to Remove from USER Permissions  ######################

$Commandlets = @($Commandlist | Sort-Object name -Unique | select name | OGV -T "select Commandlet" -PassThru).name

###########################################################################################################
############ Process above selection ######################################################################

$Roleentrytypes = $Commandlist | where { $_.Name -in $Commandlets } ; $list = @()

Foreach ($item in $Roleentrytypes){ Foreach ($i in $item.parameters) { $list +=  [PSCustomObject]@{ commandlet = $item.Name ; Role = $item.role ;Parameter = $i }}}

$Selection = $list | sort-object commandlet,parameter | OGV -T "Select Parameters to Remove From Enduser RBAC Role" -PassThru

$Update_Roles = @($Selection | Sort-Object role -Unique).Role

Foreach ($URole in $Update_Roles) { New-ManagementRole -Name $([String]$URole + $Suffix) -Description @(Get-ManagementRole $URole).Description -Parent $URole }

Foreach ($Sitem in $Selection) { set-ManagementRoleEntry $([String]$Sitem.role + [String]$Suffix + "\" + [String]$Sitem.commandlet) -Parameters $Sitem.parameter -RemoveParameter }

###########################################################################################################
############ Create New Policy and REPLACE above Modifications in DEFAULT #################################

$RBAC = Get-RoleAssignmentPolicy | where { $_.IsDefault -eq $true };

Foreach ($URole in $Update_Roles) { $RBAC.AssignedRoles.RemoveAt($RBAC.AssignedRoles.IndexOf($URole)) } ;

[Array]$NewRBACroles = $RBAC.AssignedRoles ;

Foreach ($URole in $Update_Roles) { $NewRBACroles += $([String]$URole + $Suffix)} ;

New-RoleAssignmentPolicy -Name $NEW_RBAC -Description $RBAC.Description -Roles $NewRBACroles

###########################################################################################################
############ Assign above policy to users #################################################################

# read Mailboxes
$allusers = try { Get-EXOMailbox -ResultSize unlimited -PropertySets All -EA stop } catch { Get-Mailbox -ResultSize unlimited }

# Select users - Out-GridView
$selectedMBXs = $allusers | select Use*e,pri*s,Disp*e,Ex*id | Out-GridView -T "Select Users to JunkMail Config" -PassThru

# double-check selection
$selectedMBXs

# Apply changes
Foreach ($MBX in $allusers) {
Set-Mailbox $MBX.ExternalDirectoryObjectId -RoleAssignmentPolicy $NEW_RBAC
Set-MailboxJunkEmailConfiguration $MBX.ExternalDirectoryObjectId -Enabled $true }
###########################################################################################################