
https://protection.office.com/dkimv2
https://docs.microsoft.com/en-us/powershell/module/exchange/new-dkimsigningconfig


try 1x to get the values in Error

New-DkimSigningConfig -DomainName contoso.com -Enabled $true

ADD CNAME like below

FROM hostname 1                     Points to 1
selector1._domainkey                copy value from PS above

FROM hostname 2                     Points to 2
selector2._domainkey                copy value from PS above

run again after values are there To ENABLE

New-DkimSigningConfig -DomainName contoso.com -Enabled $true