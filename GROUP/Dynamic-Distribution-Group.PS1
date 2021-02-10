
$GroupNAME = "MS_DDG"

# version 1 - Domain filter

New-DynamicDistributionGroup $GroupNAME -RecipientFilter {PrimarySmtpAddress -like "*domain.com"}


# version 2

# 2.1 Get Domain filter 
$UsersList = Get-Recipient | where {$_.PrimarySmtpAddress -like "*domain.com"}

# 2.2 set department
$UsersList | foreach {Set-User $_.Identity -Office "MS"}

# 2.3 group filtered by department
New-DynamicDistributionGroup "MS_DDG" -RecipientFilter {Office -like "MS"}


# Check filter
$GroupNAME = "MS_DDG"
Get-Recipient -RecipientPreviewFilter (Get-DynamicDistributiongroup $GroupNAME).LdapRecipientFilter