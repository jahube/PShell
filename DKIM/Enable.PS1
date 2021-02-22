https://protection.office.com/dkimv2
https://docs.microsoft.com/en-us/powershell/module/exchange/new-dkimsigningconfig

try 1x to get the values in Error

New-DkimSigningConfig -DomainName contoso.com -Enabled $false

ADD CNAME like below

FROM hostname 1                     Points to 1
selector1._domainkey                copy value from PS above

FROM hostname 2                     Points to 2
selector2._domainkey                copy value from PS above

run again after values are there To ENABLE
Set-DkimSigningConfig -Identity contoso.com -Enabled $true


# in case it gets stuck try

# New-DkimSigningConfig -DomainName contoso.com -Enabled $false
#disable
Set-DkimSigningConfig -Identity contoso.com -Enabled $false

# wait 30 Minutes <-> 2h

# enable
Set-DkimSigningConfig -Identity contoso.com -Enabled $true

# only in rare cases rotate between 1<>2 to quicklz replace invalid values and skip 4 days replication time
Rotate-DkimSigningConfig -Identity contoso.com