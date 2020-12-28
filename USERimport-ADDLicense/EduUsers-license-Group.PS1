$users = Get-Msoluser -All 

$students = $users.where({$_.licenses.AccountSkuId -match 'STUDENT'})
$teachers = $users.where({$_.licenses.AccountSkuId -match 'FACULTY'})

#NEW
$Studentsgroup = New-DistributionGroup -Name "Students1" -Type "Security" -Members $students.userprincipalname
$Teachersgroup = New-DistributionGroup -Name "Teachers1" -Type "Security" -Members $Teachers.userprincipalname


# (2) long version

#create first
$Studentsgroup2 = New-DistributionGroup -Name "Students2" -Type "Security"
$Teachersgroup2 = New-DistributionGroup -Name "Teachers2" -Type "Security"

#Get + Add
$Studentsgroup2 = get-DistributionGroup "Students1" ; $students | % { Add-DistributionGroupMember $Studentsgroup2.alias -Member $_.userprincipalname }
$Teachersgroup2 = get-DistributionGroup "Teachers1" ; $Teachers | % { Add-DistributionGroupMember $Teachersgroup2.alias -Member $_.userprincipalname }


# (3) oneliner
# New-DistributionGroup -Name "Students1" -Type "Security" -Members ((Get-Msoluser -All).where({$_.licenses.AccountSkuId -match 'STUDENT'})).userprincipalname