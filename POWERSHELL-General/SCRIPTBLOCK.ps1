######################
#  From SCRIPTBLOCK  #
######################

$command = @'
<# REPLACE LINE WITH SCRIPTBLOCK #>
'@

####### after adjusting above - run the below ###############
$session = Get-PSSession -InstanceId (Get-OrganizationConfig).RunspaceId.Guid
$myscriptblock = [scriptblock]::Create("$command")
Invoke-Command -Session $session -ScriptBlock $myscriptblock
 

###############
#  from FILE  #
#########################
$PATH = "C:\File.PS1"   # adjust file Path
#########################

$command = Get-Content $PATH
$session = Get-PSSession -InstanceId (Get-OrganizationConfig).RunspaceId.Guid
$ScriptBlock= [scriptblock]::Create("$command")
Invoke-Command -Session $session -ScriptBlock $ScriptBlock