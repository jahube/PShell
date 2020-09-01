
#  source https://social.technet.microsoft.com/Forums/ie/en-US/f2fa54bf-2cf7-4fac-8d7d-0a0909a58547/error-preparing-schema-for-exchange-2013?forum=exchangesvrdeploy

$error.Clear();

          #

          # O15# 2844081 - Create PartnerApplication "Exchange Online" in DC and On-Premise

          #

          $exch = [Microsoft.Exchange.Data.Directory.SystemConfiguration.WellknownPartnerApplicationIdentifiers]::Exchange;

          $exchApp = Get-PartnerApplication $exch -ErrorAction SilentlyContinue -DomainController $RoleDomainController | Where { $_.UseAuthServer };

          if ($exchApp -eq $null)

          {

              $exchAppName = "Exchange Online";

              $exchApp = New-PartnerApplication -Name $exchAppName -ApplicationIdentifier $exch -Enabled $RoleIsDatacenter -AcceptSecurityIdentifierInformation $false -DomainController $RoleDomainController;

          }

          # Create application account for Exchange

          $appAccountName = $exchApp.Name + "-ApplicationAccount";

          $appAccount = Get-LinkedUser -Identity $appAccountName -ErrorAction SilentlyContinue -DomainController $RoleDomainController;

          if ($appAccount -eq $null)

          {

            $appAccountUpn = $appAccountName.Replace(" ", "_") + "@" + $RoleFullyQualifiedDomainName;

            $appAccount = New-LinkedUser -Name $appAccountName -UserPrincipalName $appAccountUpn -DomainController $RoleDomainController;

            New-ManagementRoleAssignment -Role "UserApplication" -User $appAccount.Identity -DomainController $RoleDomainController;

            New-ManagementRoleAssignment -Role "ArchiveApplication" -User $appAccount.Identity -DomainController $RoleDomainController;

            New-ManagementRoleAssignment -Role "LegalHoldApplication" -User $appAccount.Identity -DomainController $RoleDomainController;

            New-ManagementRoleAssignment -Role "Mailbox Search" -User $appAccount.Identity -DomainController $RoleDomainController;

            New-ManagementRoleAssignment -Role "TeamMailboxLifecycleApplication" -User $appAccount.Identity -DomainController $RoleDomainController;

            New-ManagementRoleAssignment -Role "MailboxSearchApplication" -User $appAccount.Identity -DomainController $RoleDomainController;

            Set-PartnerApplication -Identity $exchApp.Identity -LinkedAccount $appAccount.Identity -DomainController $RoleDomainController;;

          }