# source https://social.technet.microsoft.com/Forums/en-US/842b5672-8528-40d2-a620-2d80d549e1e5/error-when-installing-exchange-server-2016-in-an-environment-with-exchange-server-2010?forum=Exch2016SD

$error.Clear();

            #

            # O15# 2844081 - Create PartnerApplication "Exchange Online" in DC and On-Premise

            #

            $exch = [Microsoft.Exchange.Data.Directory.SystemConfiguration.WellknownPartnerApplicationIdentifiers]::Exchange;

            $exchApp = Get-PartnerApplication $exch -ErrorAction SilentlyContinue -DomainController $RoleDomainController | Where { $_.UseAuthServer } | Where { [string]::IsNullOrEmpty($_.IssuerIdentifier)};

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

                Set-PartnerApplication -Identity $exchApp.Identity -LinkedAccount $appAccount.Identity -DomainController $RoleDomainController;

            }


            foreach ($roleName in ("UserApplication", "ArchiveApplication", "LegalHoldApplication", "Mailbox Search", "TeamMailboxLifecycleApplication", "MailboxSearchApplication", "MeetingGraphApplication"))

            {

                $roleIdentity = Get-ManagementRole $roleName -DomainController $RoleDomainController;

                $roleAssignment = Get-ManagementRoleAssignment -Role $roleIdentity.Identity -RoleAssignee $appAccount.Identity -DomainController $RoleDomainController;

                if ($roleAssignment -eq $null)

                {

                    New-ManagementRoleAssignment -Role $roleName -User $appAccount.Identity -DomainController $RoleDomainController;

                }

            }