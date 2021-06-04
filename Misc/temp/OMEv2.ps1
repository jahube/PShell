
<#

The script is developed by Victor Legat & Daniel David

### Version 1.1 - April 13, 2018 ###
- if AADRM module is missing will automatically install
- export AADRM templates & permissions ( CSV, XML)
- dump all actions the script is doind in a logg file
- dump initial configuration when connectins to the Office 365 (to have a reference before doing any changes)
- renames sections to know what cmdlet was executed
- resolved minor display issues


### Version 1.0 - February 26, 2018 ###

What script is doing:

Ensure that the administrator has MSOL and AADRM modules and can connect to MSOL, AADRM and EXO
Identify in which scenario customer currently is:
 - No OME configured before
 - Enabled OMEv1 only with on premises AD RMS
 - Enabled OMEv1 only with Azure AD RMS
 - Enabled OMEV2 only 
 - Have both OMEv1, OMEv2
We added an automatic way to configure OMEv1, OMEv2 taking into consideration the followings:
- OMEv1 cannot be enabled if OMEv2 is already active
  - All Transport Rules of OMEv2 should be disabled temporary
  - Internal encryption should be disabled
  - Once OMEv1 is enabled both internal encryption and previous Transport Rules have to be re-enabled
- For customers that still want to configure OMEv1 (legacy) as we don’t have any official public documentation at the moment we integrated the steps in the script
   - We are automatically getting the tenant region from the Organization Config to complete the OMEv1 configuration
We added the possibility to disable  OMEv1, OMEv2 or both (disabling and reactivating the transport rules)
We export on the console (currently; soon on an external file, too) the current configuration, AIP logs and templates
We are looking for a known issue regarding OME:
- If there are subscriptions that allow use of AIP 
- If OME is configured to allow OWA and ActiveSync
- If “Protect” button is enabled or not
- If features like EDiscoverySuperUserEnabled, JournalReportDecryptionEnabled, SearchEnabled, AllowRMSSupportForUnenlightenedApps are enabled
  - If old OMEv1 templates used by the OMEv2 transport rules
Open/Clear the templates location from Registry and cached folders
#>

$Disclaimer ='Note: Before you run the script: 

The sample scripts are not supported under any Microsoft standard support program or service. 
The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims 
all implied warranties including, without limitation, any implied warranties of merchantability 
or of fitness for a particular purpose. The entire risk arising out of the use or performance of 
the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, 
or anyone else involved in the creation, production, or delivery of the scripts be liable for any 
damages whatsoever (including, without limitation, damages for loss of business profits, business 
interruption, loss of business information, or other pecuniary loss) arising out of the use of or 
inability to use the sample scripts or documentation, even if Microsoft has been advised of the 
possibility of such damages.'

function Show-Menu {

    # Read cred stored
    $global:CredPath = "$HOME\PSSecureCredentials"


     
    if((test-path $global:CredPath) -eq $false) {
        md $CredPath
    }


    $menu=@"
1 => Connect to AADRM (AIP), MSOL and Exchange Online
2 => Configure OME to use only v2 (New version)
3 => Configure OME to use only v1
4 => Configure OME to use both v1 and v2
5 => Disable OME
6 => View Current Status of OME
7 => View Templates configuration
8 => Check if any known configuration issue
9 => Show AIP Logs
10 => Check templates/labels cached folders
11 => Check registry keys for templates/labels 
Q => Quit
Select a task by number or Q to quit
"@
    $menuprompt = $null

    Clear-Host
    $title = "`n=== Office Message Encryption/ Azure Information Protection ==="
    if (!($menuprompt)) 
    {
        $menuprompt+="="*$title.Length
    }
    Write-Host $menuprompt
    Write-Host $title
    Write-Host $menuprompt
    $r = Read-Host $menu

    Switch ($r) {
        "1" {
            Write-Host "=== Connect to AADRM (AIP), MSOL and Exchange Online ===" -ForegroundColor Green
            Connect-AADRMandEXO
            sleep -Seconds 2
            Check-OMEStatus
            Read-Host "Press [ENTER] to reload the menu"
            Show-Menu
        }
 
        "2" {
            Write-Host "`=== Configure OME to use only v2 (New version) ===" -ForegroundColor Green
            Config-OMEv2
            Read-Host "Press [ENTER] to reload the menu"
            Show-Menu
   
        }
 
        "3" {
            Write-Host "`n=== Configure OME to use only v1 ===" -ForegroundColor Green
            Config-OMEv1
            Read-Host "Press [ENTER] to reload the menu"
            Show-Menu
        }

        "4" {
            Write-Host "`=== Configure OME to use both v1 and v2 ===" -ForegroundColor Green
            Config-OMEv1andv2
            Read-Host "Press [ENTER] to reload the menu"
            Show-Menu
        }
 
        "5" {
            Write-Host "`n=== Disable OME ===" -ForegroundColor Green
            Disable-OME
            Read-Host "Press [ENTER] to reload the menu"
            Show-Menu
        }
 
        "6" {
            Write-Host "`n=== View Current Status of OME ===" -ForegroundColor Green
            Check-OMEStatus
            Read-Host "Press [ENTER] to reload the menu"
            Show-Menu
        }

        "7" {
            Write-Host "=== View Templates configuration ===" -ForegroundColor Green
            Get-TemplatesConfig
            Read-Host "Press [ENTER] to reload the menu"
            Show-Menu    
        }
 
        "8" {
            Write-Host "`n=== Check if any known configuration issue ===" -ForegroundColor Green
            Check-ConfigIssue
            Read-Host "Press [ENTER] to reload the menu"
            Show-Menu
        }
 
        "9" {
            Write-Host "`n=== Show AIP Logs ===" -ForegroundColor Green
            Show-AIPLogs
            Read-Host "Press [ENTER] to reload the menu"
            Show-Menu
        }

        "10" {
            Write-Host "`n=== Check templates/labels cached folder ===" -ForegroundColor Green
            Check-CacheFolder
            Read-Host "Press [ENTER] to reload the menu"
            Show-Menu
        }

        "11" {
            Write-Host "`n=== Check registry settings ===" -ForegroundColor Green
            Check-RegistrySettings
            Read-Host "Press [ENTER] to reload the menu"
            Show-Menu
        }

        "Q" {
            Write-Host "`n=== Quitting ===" -ForegroundColor Cyan
            try
            {
                Disconnect-AadrmService
                Write-Host "Disconnecting Exchange Online PS Session" -ForegroundColor Cyan
                Remove-PSSession $global:session
                Exit
            }
            Catch {}
         }
 
        default {
            Write-Host "`n=== I don't understand what you want to do ===" -ForegroundColor Yellow
            Read-Host "Press [Enter] to re-load the menu"
            Show-Menu
        }
    }

    
}

function Connect-AADRMandEXO {
    if (!($PSVersionTable.PSVersion.Major -ge 3))
    {
        Write-Host "Your PowerShell version is less than minimum version 3"
        Read-Host "Press [ENTER] to exist the script; Please re-run the script after you'll update PowerShell on your machine"
        Exit
    }   
    $global:cred = Get-Credential -Message "Please Input your Global Admin credentials as we need to connect both to AIP and EXO:"
    if (($global:cred.Password -eq $Null) -or ($global:cred.UserName -eq $null))
    {
        Write-Host "Your username is null, so we cannot connect you!" -ForegroundColor Red
        Read-Host "Press [ENTER] to reload the main menu"
        Show-Menu
    }


    # Check if Azure Rights Management Administration Tool is installed
    if (!(Get-Command -Module aadrm))
    {
        Write-Host "AADRM needs to be updated or you have just updated without restarting the PC/laptop" -ForegroundColor Red
        Write-Host "We will try to install the AADRM module" -ForegroundColor Cyan
        # Start-Process  "https://www.microsoft.com/en-us/download/details.aspx?id=30339"
        Install-Module -Name AADRM
        Write-Host "Installed the AADRM module"
        Import-Module AADRM -Force
    }
    
    if (!(Get-Command -Module MSOnline))
    {
        Write-Host "Microsoft Online Services Sign-in Assistant RTW and MSOnline module needs to be installed" -ForegroundColor Red
        Start-Process  "https://docs.microsoft.com/en-us/office365/enterprise/powershell/connect-to-office-365-powershell"
        Read-Host "Re-run the script once you have the `"Microsoft Online Services Sign-in Assistant RTW and MSOnline installed`" installed"
        Exit
    }
    
    $Error.Clear()
    # Connecto to AADRM & EXO
    try
    {
        Connect-AadrmService -Credential $global:cred -ErrorAction Stop
        $global:session = New-PSSession -ConfigurationName Microsoft.Exchange  `
        -ConnectionUri https://outlook.office365.com/powershell-liveid/  `
        -Credential $global:cred -Authentication Basic -AllowRedirection
        Import-PSSession $session -AllowClobber | Out-Null
        Connect-MsolService -Credential $global:cred
    }
    catch
    {
        Write-Host "You received the following error while connecting to MSOL, AADRM and EXO: `n$($error[0].Exception.Message)" -ForegroundColor Red
        Read-Host "Hit [ENTER] to reload menu"
        Show-Menu
    }

}

Function Config-OMEv1 {
    If ((Get-AadrmConfiguration).FunctionalState -ne "enabled")
            {
    Write-Host "AADRM is not enabled; will do it now!" -ForegroundColor Cyan
    Enable-Aadrm
    }

    $region = (Get-OrganizationConfig).OrganizationId.Substring(0,3)
    Switch ($region)
    {
        {@('EUR','DEU','GBR','FRA') -contains $_} { $URL = "https://sp-rms.eu.aadrm.com/TenantManagement/ServicePartner.svc" }
        {@('NAM','CAN') -contains $_} { $URL = "https://sp-rms.na.aadrm.com/TenantManagement/ServicePartner.svc"}
        {@('APC','IND','KOR','JPN','AUS') -contains $_} { $URL = "https://sp-rms.ap.aadrm.com/TenantManagement/ServicePartner.svc" }
        'LAM' { $URL = "https://sp-rms.sa.aadrm.com/TenantManagement/ServicePartner.svc"}
    }
    Write-Host "Will configure RMS with the online key-sharing location with $URL" -ForegroundColor Green

    $AzureRMSLicensingState= $False
    $irmConfig = Get-IRMConfiguration
    if ($irmConfig.AzureRMSLicensingEnabled -ne $True)
    {
        Set-IRMConfiguration -RMSOnlineKeySharingLocation $URL
        $RMSTrustedPublishingDomain = Get-RMSTrustedPublishingDomain -ErrorAction SilentlyContinue
        If ($RMSTrustedPublishingDomain) 
        {
            $RMSTrustedPublishingDomainName =(Get-RMSTrustedPublishingDomain).Name
            Import-RMSTrustedPublishingDomain -Name $RMSTrustedPublishingDomainName  -RMSOnline -RefreshTemplates 
        }
        else
        {
            Import-RMSTrustedPublishingDomain -Name "RMS Online" -RMSOnline
        }
         Set-IRMConfiguration -InternalLicensingEnabled $True -Confirm:$False -Force
    }
    else
    {
        $TRs = Get-TransportRule
        if (!($TRs.ApplyRightsProtectionTemplate))
        {
            Set-IRMConfiguration -InternalLicensingEnabled $False -AzureRMSLicensingEnabled $False -Confirm:$False -Force
            Set-IRMConfiguration -RMSOnlineKeySharingLocation $URL -Confirm:$False -Force
            $RMSTrustedPublishingDomain = Get-RMSTrustedPublishingDomain -ErrorAction SilentlyContinue
            If ($RMSTrustedPublishingDomain) 
            {
               Import-RMSTrustedPublishingDomain -Name (Get-RMSTrustedPublishingDomain).Name -RMSOnline -RefreshTemplates
            }
            else
            {
                Import-RMSTrustedPublishingDomain -Name "RMS Online" -RMSOnline
            }
            Set-IRMConfiguration -InternalLicensingEnabled $True  -AzureRMSLicensingEnabled $True -Confirm:$False -Force
        }
        else
        {
            Foreach ($TR in $TRs)
            {
                If (($TR.ApplyRightsProtectionTemplate -ne $null) -and ($TR.State -eq "Enabled"))
                {
                    Disable-TransportRule $TR.Name -Confirm:$False
                }
            }
            Set-IRMConfiguration -InternalLicensingEnabled $False -AzureRMSLicensingEnabled $False -Confirm:$False -Force
            Set-IRMConfiguration -RMSOnlineKeySharingLocation $URL -Confirm:$False -Force
            $RMSTrustedPublishingDomain = Get-RMSTrustedPublishingDomain -ErrorAction SilentlyContinue

            If ($RMSTrustedPublishingDomain) 
            {
               Import-RMSTrustedPublishingDomain -Name (Get-RMSTrustedPublishingDomain).Name -RMSOnline -RefreshTemplates
            }
            else
            {
                Import-RMSTrustedPublishingDomain -Name "RMS Online" -RMSOnline
            }
            Set-IRMConfiguration -InternalLicensingEnabled $True -AzureRMSLicensingEnabled $True -Confirm:$False -Force
            Foreach ($TR in $TRs)
            {
                If (($TR.ApplyRightsProtectionTemplate -ne $null) -and ($TR.State -eq "Enabled"))
                {
                    Enable-TransportRule $TR.Name -Confirm:$False
                }
            }
        }
    }
}

Function Config-OMEv2 {
If ((Get-AadrmConfiguration).FunctionalState -ne "enabled")
{
    Write-Host "AADRM is not enabled; will do it now!" -ForegroundColor Cyan
    Enable-Aadrm
}

#Get the configuration information needed for message protection.
$rmsConfig = Get-AadrmConfiguration
$licenseUri = $rmsConfig.LicensingIntranetDistributionPointUrl

#Collect IRM configuration for Office 365.
$irmConfig = Get-IRMConfiguration
$list = $irmConfig.LicensingLocation
if (!$list) { $list = @() }
if (!$list.Contains($licenseUri)) { $list += $licenseUri }

#Enable message protection for Office 365.
Set-IRMConfiguration -LicensingLocation $list
Set-IRMConfiguration -AzureRMSLicensingEnabled $true -InternalLicensingEnabled $true

#Enable new Protect button in Outlook on the Web
Set-IRMConfiguration -SimplifiedClientAccessEnabled $true
}

Function Config-OMEv1andv2 {
    Config-OMEv1
    Config-OMEv2
}

Function Disable-OME {

    #Collect IRM configuration for Office 365.
    $irmConfig = Get-IRMConfiguration    
    $OMEv1=$false
    $OMEv2=$false
    If ($irmConfig.AzureRMSLicensingEnabled -eq $true)
    {
        $OMEv2 =$true
    }
    If ($irmConfig.RMSOnlineKeySharingLocation -ne $null)          
    {
        $OMEv1=$true
    } 
    
    $DisableMenu=@"
1 => Disable AADRM
2 => Disable IRM
3 => Deactivate OMEv1
4 => Deactivate OMEv2
Q => Back to Main Menu
Select a task by number or Q to return to main menu
"@
    $menuprompt=$null
    Clear-Host
    $title = "Disable Office Message Encryption (OME)/Azure Information Protection (AIP)"
    if (!($menuprompt)) 
    {
        $menuprompt+="="*$title.Length
    }
    Write-Host $menuprompt
    Write-Host $title
    Write-Host $menuprompt
    $r = Read-Host $DisableMenu
    
    Switch ($r) {
"1" {
        if ((Get-AadrmConfiguration).FunctionalState -ne "enabled") 
        {
            Write-Host "AADRM is already disabled on the tenant level" -ForegroundColor Red
        }
        else
        {
            Write-Host "Disabling AADRM" -ForegroundColor Green
            Disable-Aadrm
        }
        Disable-OME
    }
 
"2" {
        If ($irmConfig.InternalLicensingEnabled -eq $True)
        {
            Write-Host "Disable IRM for Internal use"
            Set-IRMConfiguration -InternalLicensingEnabled $False 
        }
        else
        {
            Write-Host "IRM already disabled"
        }
        Read-Host "Press [ENTER] to reload the menu"
        Disable-OME
   
}
 
"3" {
        $TRs = Get-TransportRule
        If ($OMEv1 -eq $True) 
        {
            if ($OMEv2 -eq $true)
            {
                Write-Host "Temporary Deactivating OMEv2" -ForegroundColor Green
            
                # Disable TR with OMEv2
                Foreach ($TR in $TRs)
                {
                    If (($TR.ApplyRightsProtectionTemplate -ne $null) -and ($TR.State -eq "Enabled"))
                    {
                        Disable-TransportRule $TR.Name -Confirm:$False
                    }
                }
 
                 # Disable TR with OMEv1
                Foreach ($TR in $TRs)
                {
                    If (($TR.ApplyOME -eq $true) -and ($TR.State -eq "Enabled"))
                    {
                        Disable-TransportRule $TR.Name -Confirm:$False
                    }
                }   

                Set-IRMConfiguration -AzureRMSLicensingEnabled $false -InternalLicensingEnabled $False -RMSOnlineKeySharingLocation $null -Confirm:$false -Force
                Write-Host "Reactivating OMEv2" -ForegroundColor Green
                Set-IRMConfiguration -AzureRMSLicensingEnabled $true -InternalLicensingEnabled $True -Confirm:$false -Force
                # Enable TR with OMEv2
                Foreach ($TR in $TRs)
                {
                    If (($TR.ApplyRightsProtectionTemplate -ne $null) -and ($TR.State -eq "Enabled"))
                    {
                        Enable-TransportRule $TR.Name -Confirm:$False
                    }
                }
            }

            else 
            {
                Write-Host "Deactivating OMEv1" -ForegroundColor Green
                # Disable TR with OMEv1
                Foreach ($TR in $TRs)
                {
                    If (($TR.ApplyOME -eq $true) -and ($TR.State -eq "Enabled"))
                    {
                        Disable-TransportRule $TR.Name -Confirm:$False
                    }
                }   
                Set-IRMConfiguration -RMSOnlineKeySharingLocation $null -InternalLicensingEnabled $false -Confirm:$false -Force
            }
        }
        else
        {
            Write-Host "OMEv1 wasn't enabled" -ForegroundColor Red
        }

        Read-Host "Press [ENTER] to reload the menu"
        Disable-OME
}

"4" {
        If ($OMEv2 -eq $True) 
        {
            Write-Host "Deactivating OMEv2" -ForegroundColor Green
            # Disable TR with OMEv2
            Foreach ($TR in $TRs)
            {
                If (($TR.ApplyRightsProtectionTemplate -ne $null) -and ($TR.State -eq "Enabled"))
                {
                    Disable-TransportRule $TR.Name -Confirm:$False
                }
            }
            Set-IRMConfiguration -AzureRMSLicensingEnabled $False
        }
        else
        {
            Write-Host "OMEv2 wasn't enabled" -ForegroundColor Red
        }
        Read-Host "Press [ENTER] to reload the menu"
        Disable-OME
}
 
"Q" {
    Write-Host "Back to Main Menu" -ForegroundColor Green
    try
    {    
        Read-Host "Press [ENTER] to reload the Main Menu"
        Show-Menu
    }
    Catch {Show-Menu}

}
 
default {
    Write-Host "I don't understand what you want to do." -ForegroundColor Yellow
    Write-Host $menuprompt
    Write-Host $title
    Write-Host $menuprompt
    $r = Read-Host $DisableMenu
 }
}
    
}

Function Check-OMEStatus {
    Write-Host "`n=== Current IRM Status ===" -ForegroundColor Cyan
    Write-Host "AADRM is $((Get-AadrmConfiguration).FunctionalState)"

    $IRM = Get-IRMConfiguration
    Switch ($IRM)
    {
        {$IRM.AzureRMSLicensingEnabled -eq $true}              {Write-Host "OMEv2 enabled" -ForegroundColor Cyan}
        {$IRM.RMSOnlineKeySharingLocation -ne $null}           {Write-Host "OMEv1 enabled" -ForegroundColor Cyan}  
        {(($IRM.ServiceLocation -eq $null) -and ($IRM.PublishingLocation -eq $null)) -and ($IRM.RMSOnlineKeySharingLocation -ne $null) }     {Write-Host "OMEv1 enabled but Import-RMSTrustedPublishingDomain not run" -ForegroundColor Cyan}
        {(($IRM.ServiceLocation -ne $null) -and ($IRM.PublishingLocation -ne $null)) -and ($IRM.RMSOnlineKeySharingLocation -eq $null) -and ($IRM.ServiceLocation -notmatch "aadrm.com")}     {Write-Host "OMEv1 enabled but with on premises AD RMS" -ForegroundColor Cyan}
        {(($IRM.ServiceLocation -ne $null) -and ($IRM.PublishingLocation -ne $null)) -and ($IRM.RMSOnlineKeySharingLocation -eq $null) -and ($IRM.ServiceLocation -match "aadrm.com")}     {Write-Host "OMEv1 was enabled with Azure AD RMS" -ForegroundColor Cyan}
    }


    Write-Host "`n=== RMSTrustedPublishingDomain Configuration === (Get-RMSTrustedPublishingDomain)"
    Get-RMSTrustedPublishingDomain -ErrorAction SilentlyContinue


    # Check who's manage the Key?"
    $KeyType = (Get-AadrmKeys).KeyType
    switch ($KeyType) 
    {
        "Microsoft-managed" {Write-Host "AADRM Key is managed by Azure Information Protection - (Get-AadrmKeys)"}
        "customer-managed"  {Write-Host "AADRM Key is managed by customer (BYOK)- (Get-AadrmKeys)"}
    }

    Write-Host "`n=== IRMConfiguration Status === (Get-IRMConfiguration)" -ForegroundColor Cyan
    $IRM 

    Write-Host "`nRunning `"Test-IRMConfiguration -Sender $($global:cred.UserName)`"" -ForegroundColor Cyan
    Test-IRMConfiguration -Sender $global:cred.UserName

    Write-Host "`n=== Checking OME configuration === (Get-OMEConfiguration)" -ForegroundColor Cyan
    Get-OMEConfiguration

    Write-Host "`n=== AADRM configuration === (Get-AadrmConfiguration)" -ForegroundColor Cyan
    Get-AadrmConfiguration
    Write-Host "AadrmDoNotTrackUserGroup                  : $(Get-AadrmDoNotTrackUserGroup)"
    Write-Host "MaxUseLicenseValidityTime                 : $(Get-AadrmMaxUseLicenseValidityTime)"
}

Function Get-TemplatesConfig {
    $templates = Get-AadrmTemplate 
    $temptemplates=@()
    md $PATH\TemplatesPermissions -Force | out-null
    md $PATH\Templates -Force |out-null
    Foreach ($template in $templates)
    {
        $temptemplate = New-Object -TypeName psobject 
        $temptemplate | Add-Member -Name TemplateId -Value $template.TemplateId -MemberType NoteProperty 
        
        $name = ($template.Names -match "1033").value
        if ($name -eq $null) 
        {
            $name = (($template.Names) | Select -First 1).value
        }
        $description = ($template.Descriptions -match "1033").value
        if ($Description -eq $null) 
        {
            $Description = (($template.Descriptions) | Select -First 1).value
        }

        $temptemplate | Add-Member -Name Name -Value $name  -MemberType NoteProperty 
        $temptemplate | Add-Member -Name Description -Value $description  -MemberType NoteProperty 
        $temptemplate | Add-Member -Name Status -Value $template.Status -MemberType NoteProperty 
        $temptemplate | Add-Member -Name ContentExpirationDate -Value $template.ContentExpirationDate -MemberType NoteProperty 
        $temptemplate | Add-Member -Name ContentExpirationOption -Value $template.ContentExpirationOption -MemberType NoteProperty 
        $temptemplate | Add-Member -Name LicenseValidityDuration -Value $template.LicenseValidityDuration -MemberType NoteProperty 
        $temptemplate | Add-Member -Name ReadOnly -Value $template.ReadOnly -MemberType NoteProperty 
        $temptemplate | Add-Member -Name LastModifiedTimeStamp -Value $template.LastModifiedTimeStamp -MemberType NoteProperty 
        $temptemplate | Add-Member -Name ScopedIdentities -Value $template.ScopedIdentities -MemberType NoteProperty 
        $temptemplate | Add-Member -Name EnableInLegacyApps -Value $template.EnableInLegacyApps -MemberType NoteProperty 
        $temptemplates += $temptemplate
        Write-Host "Rights definitions for template $name (GUID: $($template.TemplateId.Guid))" -ForegroundColor Green
        (Get-AadrmTemplate -TemplateId $template.TemplateId.Guid).RightsDefinitions | Tee-Object -FilePath "$PATH`\TemplatesPermissions\$ts`_$($name -replace"\\"," ")`_template_permissions.csv"

    }

    Write-Host "Exporting templates in CSV and XML"
    $temptemplates | Export-Csv "$PATH`\Templates\$ts`_templates.csv"
    $templates | Export-Clixml "$PATH`\Templates\$ts`_templates.xml"
    $temptemplates | Out-GridView  -Title "All Templates"
}

Function Check-ConfigIssue {
    [boolean]$anyissue = $False
    $irmConfig = Get-IRMConfiguration
    if (($irmConfig.AzureRMSLicensingEnabled -eq $True) -and ($irmConfig.RMSOnlineKeySharingLocation -eq $null))
    {
        $TRs =  Get-TransportRule
        Foreach ($TR in $TRs) 
        {
            if ($TR.ApplyOME -eq $True)
            {
                Write-Host "Only OMEv2 is enabled but you are applying OMEv1 on Transport Rule: $($TR.Name)" -ForegroundColor Red
                $anyissue = $True
            }
        }
    }
    
    $SKUs = Get-MsolSubscription
    if (!(($SKUs.SkuPartNumber -contains "EMSPREMIUM") -or  ($SKUs.SkuPartNumber -contains "EMS") -or ($SKUs.SkuPartNumber -contains "RMS_PREMIUM") -or ($SKUs.SkuPartNumber -contains "RMS_S_PREMIUM") -or ($SKUs.SkuPartNumber -contains "RMS_S_ENTERPRISE") -or ($SKUs.SkuPartNumber -contains "RIGHTSMANAGEMENT") -or ($SKUs.SkuPartNumber -contains "ENTERPRISEPACK") -or ($SKUs.SkuPartNumber -contains "ENTERPRISEPREMIUM") -or ($SKUs.SkuPartNumber -contains "EMSPREMIUM")))
    {
        Write-Host "No available subscription which contains Azure Informaion Protection capability" -ForegroundColor Red
        $anyissue = $True
    }

    if ($irmConfig.SimplifiedClientAccessEnabled -eq $False) 
    {
        Write-Host "Protect button is Disables in OWA" -ForegroundColor Red
        $anyissue = $True
    }

    if ($irmConfig.ClientAccessServerEnabled -eq $False) 
    {
        Write-Host "IRM disabled in OWA and ActiveSync" -ForegroundColor Red
        $anyissue = $True
    }
    if ($irmConfig.EDiscoverySuperUserEnabled -eq $False) 
    {
        Write-Host "EDiscovery cannot decrypt protected messages" -ForegroundColor Red
        $anyissue = $True
    }
    if ($irmConfig.JournalReportDecryptionEnabled -eq $False) 
    {
        Write-Host "Journal Report Decryption is disabled" -ForegroundColor Red
        $anyissue = $True
    }
    if ($irmConfig.SearchEnabled -eq $False) 
    {
        Write-Host "Search in OWA is disabled for protected documents" -ForegroundColor Red
        $anyissue = $True
    }

    if ((Get-ActiveSyncOrganizationSettings).AllowRMSSupportForUnenlightenedApps -eq $true) 
    {
        Write-Host "AllowRMSSupportForUnenlightenedApps is enabled. Security issues?" -ForegroundColor Yellow
        $anyissue = $True
    }
    

    if (!$anyissue) 
    {
        Write-Host "No known issue found!" -ForegroundColor Green
    }
}

Function Show-AIPLogs {
    # Usage activity for the Azure Information Protection client, logged in the local Windows Applications and Services event log, Azure Information Protection
    # Downloads Azure Rights Management logs (from last day) to local storage.
    Write-Host "Downloads Azure Rights Management logs (from last day) to local storage in `"$path\Logs`"" -ForegroundColor Cyan
    Get-AadrmAdminLog -Path "$path\Logs\AdminLog_$ts.log"  -FromTime (Get-Date).Date.AddDays(-1) -ToTime (Get-Date)
    Get-AadrmUserLog -Path "$path\Logs" -ForDate (Get-Date).Date
    
    if ((Get-AadrmUsageLogFeature) -eq $true)
    {
        Get-AadrmUsageLog -Path "$path\Logs"  -Verbose
    }
    else
    {
        Write-Host "AadrmUsageLogFeature is turned off"
    }

}

Function Check-CacheFolder {
    $menu=@"
1 => Show templates/labels cached folder
2 => Remove templates/labels cached folder
Q => Back to main menu
Select a task by number or Q to go back
"@

    Clear-Host
    $title = "Check templates/labels cached folder"
    if (!($menuprompt)) 
    {
        $menuprompt+="="*$title.Length
    }
    Write-Host $menuprompt
    Write-Host $title
    Write-Host $menuprompt
    $r = Read-Host $menu

    
    Switch ($r) {
    "1" {
        Write-Host "Show templates/labels cached folder" -ForegroundColor Green
        Write-Host "Troubleshooting logs for the Azure Information Protection client, located in `"c:\%localappdata%\Microsoft\MSIPC`""
        explorer.exe "$env:LOCALAPPDATA\Microsoft\MSIPC"
        Read-Host "Press [ENTER] to reload the main menu"
        Show-Menu
    }
 
    "2" {
        Write-Host "Remove templates/labels cached folder" -ForegroundColor Green
        Remove-Item –path "$env:LOCALAPPDATA\Microsoft\MSIPC" –recurse 
        Read-Host "Press [ENTER] to reload the mainmenu"
        Show-Menu
   
    }

    "Q" {
            Read-Host "Press [Enter] to re-load the main menu"
            Show-Menu
        }
 
    default {
        Write-Host "I don't understand what you want to do." -ForegroundColor Yellow
        Read-Host "Press [Enter] to re-load the main menu"
        Show-Menu
    }
    

    }
}
   
Function Check-RegistrySettings {
    $menu=@"
1 => Show registry keys for templates/labels
2 => Remove registry keys for templates/labels
Q => Back to main menu
Select a task by number or Q to go back
"@

    Clear-Host
    $title = "Check registry keys for templates/labels"
    if (!($menuprompt)) 
    {
        $menuprompt+="="*$title.Length
    }
    Write-Host $menuprompt
    Write-Host $title
    Write-Host $menuprompt
    $r = Read-Host $menu

    
    Switch ($r) {
    "1" {
        Write-Host "Show registry keys for templates/labels" -ForegroundColor Green
        # Check service discovery settings are configured in the registry
        # x64
        $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit"
        $name = "LastKey"
        $value = "HKCU\Software\Classes\Local Settings\Software\Microsoft\MSIPC"
        New-ItemProperty -Path $regPath -Name $name -Value $value -PropertyType String -Force | Out-Null
        Start-Process RegEdit
        Read-Host "Press [ENTER] to reload the main menu"
        Show-Menu
    }
 
    "2" {
        Write-Host "Remove registry keys for templates/labels" -ForegroundColor Green
        # Delete RMS registry settings for the user.
        # Open Regedit.exe
        # HKCU\Software\Classes\Local Settings\Software\Microsoft
        # Delete the MSIPC key
        Remove-ItemProperty -Path "HKCU\Software\Classes\Local Settings\Software\Microsoft" -Name "MSIPC" -Confirm:$False
        Read-Host "Press [ENTER] to reload the mainmenu"
        Show-Menu
   
    }

    "Q" {
            Read-Host "Press [Enter] to re-load the main menu"
            Show-Menu
        }
 
    default {
        Write-Host "I don't understand what you want to do." -ForegroundColor Yellow
        Read-Host "Press [Enter] to re-load the main menu"
        Show-Menu
    }
    

    }
}


#region Main Script
Clear-Host
$FormatEnumerationLimit = -1
Write-Host $Disclaimer -ForegroundColor Red
Read-Host "Hit [Enter] to load Main Menu; if you don't agree with the disclaimer feel free to exit from the Menu"
$ts = Get-Date -Format yyyyMMdd_HHmmss
$path=[Environment]::GetFolderPath("Desktop")+"\$($ts)_Config_AIP"
md "$path"
md "$path\Logs" 
Start-transcript -Path "$path\OMEv2Transcript_$ts.txt"
Write-Host "All the logs will be saved to the following location: $path"
Show-Menu
Stop-Transcript
#endregion Main Script
