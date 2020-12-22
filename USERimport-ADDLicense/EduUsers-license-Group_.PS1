$users = Get-Msoluser -All 
$groups = Get-MsolGroup -All -

$user = "admin@domain.com"
$test = (Get-MsolUser -userprincipalname $user).Licenses.ServiceStatus.serviceplan.ServiceName
$test = (Get-MsolUser -userprincipalname $user).Licenses.ServiceStatus
$test = (Get-MsolUser -userprincipalname $user)
$test | fl *license*

FACULTY
$students = $users.where({$_.licenses.AccountSkuId -match 'STUDENT'})
$teachers = $users.where({$_.licenses.AccountSkuId -match 'FACULTY'})
$users | FT userprincipalname, Licenses

$licenses = Get-MsolAccountSku
$licenses.AccountSkuId

$A1Student =  $licenses.where({$_.AccountSkuId -match "STANDARDWOFFPACK" })[0].AccountSkuId
$A1Faculty =  $licenses.where({$_.AccountSkuId -match "STANDARDWOFFPACK" })[0].AccountSkuId
$A3Student =  $licenses.where({$_.AccountSkuId -match "M365EDU_A3_STUDENT" })[0].AccountSkuId
$A3Faculty =  $licenses.where({$_.AccountSkuId -match "M365EDU_A3_FACULTY" })[0].AccountSkuId
$A5Student =  $licenses.where({$_.AccountSkuId -match "M365EDU_A5_STUDENT" })[0].AccountSkuId
$A5Faculty =  $licenses.where({$_.AccountSkuId -match "M365EDU_A5_FACULTY" })[0].AccountSkuId

$A1Students = $users.where({$A3Student -in $_.licenses.AccountSkuId })
$A1Teachers = $users.where({$A3Student -in $_.licenses.AccountSkuId })
$A3Students = $users.where({$A3Student -in $_.licenses.AccountSkuId })
$A3Teachers = $users.where({$A3Faculty -in $_.licenses.AccountSkuId })
$A5Students = $users.where({$A5Student -in $_.licenses.AccountSkuId })
$A5Teachers = $users.where({$A5Faculty -in $_.licenses.AccountSkuId })
$users.licenses.AccountSkuId

$A1Students = $users.where({​​​​​​​$_.licenses.AccountSkuId -match $A3Student}​​​​​​​)
$A1Teachers = $users.where({​​​​​​​$_.licenses.AccountSkuId -match $A3Student}​​​​​​​)
$A3Students = $users.where({​​​​​​​$_.licenses.AccountSkuId -match $A3Student}​​​​​​​)
$A3Teachers = $users.where({​​​​​​​$_.licenses.AccountSkuId -match $A3Faculty}​​​​​​​)
$A5Students = $users.where({​​​​​​​$_.licenses.AccountSkuId -match $A5Student}​​​​​​​)
$A5Teachers = $users.where({​​​​​​​$_.licenses.AccountSkuId -match $A5Faculty}​​​​​​​)

$users = Get-Msoluser -All 

$students = $users.where({$_.licenses.AccountSkuId -match 'STUDENT'})
$teachers = $users.where({$_.licenses.AccountSkuId -match 'FACULTY'})

#NEW
$Studentsgroup = New-DistributionGroup -Name "Students1" -Type "Security" -Members $students.userprincipalname
$Teachersgroup = New-DistributionGroup -Name "Teachers1" -Type "Security" -Members $Teachers.userprincipalname

#create first
$Studentsgroup2 = New-DistributionGroup -Name "Students2" -Type "Security"
$Teachersgroup2 = New-DistributionGroup -Name "Teachers2" -Type "Security"

#Get + Add
$Studentsgroup2 = get-DistributionGroup "Students1" ; $students | % { Add-DistributionGroupMember $Studentsgroup2.alias -Member $_.userprincipalname }
$Teachersgroup2 = get-DistributionGroup "Teachers1" ; $Teachers | % { Add-DistributionGroupMember $Teachersgroup2.alias -Member $_.userprincipalname }

