############ Release ################################################################################################################################
Release-QuarantineMessage -Identity 000 -Identities @(Get-QuarantineMessage | Select-Object *ss,Me*,*ity | OGV -P -T "RELEASE").identity -Rel -F 

############ Export #################################################################################################################################
$MSG = Export-QuarantineMessage -Identity 000 -Identities @(Get-QuarantineMessage | Select-Object *ss,Me*,*ity | OGV -P -T "EXPORT").identity       
Foreach ($M in $MSG) { [IO.File]::WriteAllBytes([String]$("C:\TempQ\"+$M.Identity.Split('\')[1]+".eml"), $([Convert]::FromBase64String($m.Eml)))}   

##################### DELETE ########################################################################################################################
Delete-QuarantineMessage -Identity 000 -Identities@(Get-QuarantineMessage | Select-Object *ss,Me*,*ity | OGV -P -T "DELETE").identity -CF:$false 


##################### Long  ICM #####################################################################################################################
ICM $([scriptblock]::Create((wget "https://raw.githubusercontent.com/jahube/PShell/master/Quarantine/quarantine-Menu.PS1").Content))

##################### Long -v #######################################################################################################################
https://raw.githubusercontent.com/jahube/PShell/master/Quarantine/quarantine-Menu.PS1
#####################################################################################################################################################

$SRC = Get-QuarantineMessage | Select-Object *ivedT*,*Address,*neTyp*,Poli*,Repo*,Relea*,Exp*,Mess*Id,Identity
Release-QuarantineMessage -Identity 000 -Identities @($SRC | Out-GridView -PassThru).identity -ReleaseToAll -Force

$SRC = Get-QuarantineMessage | Select-Object *ivedT*,*Address,*neTyp*,Poli*,Repo*,Relea*,Exp*,Mess*Id,Identity
Delete-QuarantineMessage -Identity 000 -Identities @($SRC | Out-GridView -PassThru).identity

$SRC = Get-QuarantineMessage | Select-Object *ivedT*,*Address,*neTyp*,Poli*,Repo*,Relea*,Exp*,Mess*Id,Identity
$MSG = Export-QuarantineMessage -Identity 000 -Identities @($SRC | Out-GridView -PassThru).identity
Foreach ($M in $MSG) { [IO.File]::WriteAllBytes([String]$("C:\TempQ\"+$M.Identity.Split('\')[1]+".eml"), $([Convert]::FromBase64String($m.Eml)))}