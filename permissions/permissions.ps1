# https://protection.office.com/permissions eDiscovery Admin

install-module exchangeonlinemanagement

Connect-ExchangeOnline

$admin = 'admin@DOMAIN.com' # CHANGE

Add-RoleGroupMember -Identity eDiscoveryManager -Member $admin
 
install-module MSOnline

Connect-MsolService

$obj = $((get-MsolRole -RoleName 'Compliance Administrator').ObjectID.guid)

$adm = $((Get-MsolUser -UserPrincipalName $admin).ObjectID.guid)

add-MsolRoleMember -RoleObjectId $obj -RoleMemberObjectId $adm