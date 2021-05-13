# Author:  Fabrice Romelard
# source   https://techcommunity.microsoft.com/t5/office-365/powershell-script-to-export-audit-log-search-data-based-on/m-p/32658
# based on https://github.com/jahube/AuditLogs/blob/main/tmp/Split-O365AuditLogs-FromO365.ps1

	[bool]$GLOBAL:specifyPeriod = $false # if false it will be the default period time specified $DefaultPeriodToCheck (last XX days)
	[int]$GLOBAL:DefaultPeriodToCheck = -1 #last 14 days by default

	[DateTime]$GLOBAL:startDate = (get-date).AddDays(-30) # "01/01/2019 00:00" #"01/01/2019 00:00" #Format: mm/dd/yyyy hh:MM #(get-date).AddDays(-1)
	[DateTime]$GLOBAL:endDate = (get-date) # "01/31/2019 23:59" #"01/11/2019 23:59" #Format: mm/dd/yyyy hh:MM #(get-date)
	
	[bool]$GLOBAL:specifyUserIDs = $false 
    IF ($GLOBAL:specifyUserIDs) {    # $GLOBAL:SpecifiedUserIDs = "UserIdEmailAddress@yourtenant.com" #syntax: "<value1>","<value2>",..."<valueX>"
    $GLOBAL:SpecifiedUserIDs = @(Get-Mailbox -ResultSize Unlimited | select Pr*ess,Dis*me,Use*me | Out-GridView -Passthru -Title "Select User").userprincipalname }

	[bool]$GLOBAL:specifyRecordTypes = $false
	$GLOBAL:RecordTypeValues = "SharePoint" #Only one field to put, biggest products: "OneDrive" "SharePoint" "Sway" "PowerBI" "MicrosoftTeams" "MicrosoftStream"
	# Possible values: <ExchangeAdmin | ExchangeItem | ExchangeItemGroup | SharePoint | SyntheticProbe | SharePointFileOperation | OneDrive | AzureActiveDirectory | AzureActiveDirectoryAccountLogon | DataCenterSecurityCmdlet | ComplianceDLPSharePoint | Sway | ComplianceDLPExchange | SharePointSharingOperation | AzureActiveDirectoryStsLogon | SkypeForBusinessPSTNUsage | SkypeForBusinessUsersBlocked | SecurityComplianceCenterEOPCmdlet | ExchangeAggregatedOperation | PowerBIAudit | CRM | Yammer | SkypeForBusinessCmdlets | Discovery | MicrosoftTeams | MicrosoftTeamsAddOns | MicrosoftTeamsSettingsOperation | ThreatIntelligence AeD, MicrosoftStream, ThreatFinder, Project, SharePointListOperation, DataGovernance, SecurityComplianceAlerts, ThreatIntelligenceUrl, SecurityComplianceInsights, WorkplaceAnalytics, PowerAppsApp, PowerAppsPlan, ThreatIntelligenceAtpContent, LabelExplorer, TeamsHealthcare, ExchangeItemAggregated, HygieneEvent>
	

Function Split-O365AuditLogs-FromO365 ()
{
    #Get the content to process
	Write-host " -----------------------------------------" -ForegroundColor Green


##########################################################################################

# $login = "Email@domain.com"
$FolderPath = ([Environment]::GetFolderPath('MyDocuments'))
$PWlist = (Get-ChildItem $FolderPath | Where { $_.Name -match '_encrypted_password1.txt'} )[0].VersionInfo.filename
IF ($PWlist) { $login = (([string]$PWlist -split "\\")[-1] -split '_')[0] }
#$login = ([adsi]"LDAP://$(whoami /fqdn)").mail

$credpath = $([String]$FolderPath + '\' + $login + '_encrypted_password1.txt')
#Ask for credentials and store them

IF(Test-Path $credpath)
      {
$encrypted = Get-Content $credpath | ConvertTo-SecureString
$credential = New-Object System.Management.Automation.PsCredential($login, $encrypted)
        try { Connect-ExchangeOnline -Credential $credential } catch {  Connect-ExchangeOnline -UserPrincipalName $login }
      }
 ELSE {
$credential = Get-Credential $login

$credential.Password | ConvertFrom-SecureString | Out-File $credpath
# Read encrypted password

# Set variables

try { Connect-ExchangeOnline -Credential $credential } catch {  Connect-ExchangeOnline -UserPrincipalName $login }

}
$ts = Get-Date -Format yyyyMMdd_hhmmss
$DesktopPath = ([Environment]::GetFolderPath('Desktop'))
$logsPATH = mkdir "$DesktopPath\MS-Logs\Unified_Audit_Logs_$ts"

Start-Transcript "$logsPATH\Transcript_$ts.txt"
$FormatEnumerationLimit = -1

IF (!($Credential.UserName -in (get-RoleGroupMember "Organization Management").primarySMTPaddress)) { Add-RoleGroupMember "Organization Management" -Member $Credential.UserName
Try { Connect-ExchangeOnline -Credential $Credential -EA stop } catch { Connect-ExchangeOnline -UserPrincipalName $Credential.UserName } }

IF (!($USER)) { Try { $MBXs = Get-ExoMailbox -ResultSize unlimited -EA stop } catch { $MBXs = get-mailbox -ResultSize unlimited } # read mailboxes - try { ExoMBX } catch { classic }
IF ($MBXs.Count -gt "400") { $USER = Read-Host -Prompt "Affected User [Userprincipalname]" }                                                   # Above threshold - ask for manual user input
                      ELSE { $USER = @($MBXs | select Pr*ess,Dis*me,Use*me | Out-GridView -Passthru -Title "Select User").userprincipalname }} # below threshold - Out-gridview  Mailbox Select

#	$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-LiveID/ -Credential $UserCredential -Authentication Basic -AllowRedirection
#	Import-PSSession $Session

          [bool]$specifyPeriod = [bool]$GLOBAL:specifyPeriod
	[int]$DefaultPeriodToCheck = [int]$GLOBAL:DefaultPeriodToCheck
	      [DateTime]$startDate = [DateTime]$GLOBAL:startDate
	        [DateTime]$endDate = [DateTime]$GLOBAL:endDate
	     [bool]$specifyUserIDs = [bool]$GLOBAL:specifyUserIDs
	         $SpecifiedUserIDs = $GLOBAL:SpecifiedUserID
	 [bool]$specifyRecordTypes = [bool]$GLOBAL:specifyRecordTypes
	         $RecordTypeValues = $GLOBAL:RecordTypeValues
    <#
	[bool]$specifyPeriod = $true # if false it will be the default period time specified $DefaultPeriodToCheck (last XX days)
	[int]$DefaultPeriodToCheck = -14 #last 14 days by default
	[DateTime]$startDate = (get-date).AddDays(-1) # "01/01/2019 00:00" #"01/01/2019 00:00" #Format: mm/dd/yyyy hh:MM #(get-date).AddDays(-1)
	[DateTime]$endDate = (get-date) # "01/31/2019 23:59" #"01/11/2019 23:59" #Format: mm/dd/yyyy hh:MM #(get-date)
	
	[bool]$specifyUserIDs = $false
	$SpecifiedUserIDs = $USER # "UserIdEmailAddress@yourtenant.com" #syntax: "<value1>","<value2>",..."<valueX>"
	
	[bool]$specifyRecordTypes = $false
	$RecordTypeValues = "SharePoint" #Only one field to put, biggest products: "OneDrive" "SharePoint" "Sway" "PowerBI" "MicrosoftTeams" "MicrosoftStream"
	# Possible values: <ExchangeAdmin | ExchangeItem | ExchangeItemGroup | SharePoint | SyntheticProbe | SharePointFileOperation | OneDrive | AzureActiveDirectory | AzureActiveDirectoryAccountLogon | DataCenterSecurityCmdlet | ComplianceDLPSharePoint | Sway | ComplianceDLPExchange | SharePointSharingOperation | AzureActiveDirectoryStsLogon | SkypeForBusinessPSTNUsage | SkypeForBusinessUsersBlocked | SecurityComplianceCenterEOPCmdlet | ExchangeAggregatedOperation | PowerBIAudit | CRM | Yammer | SkypeForBusinessCmdlets | Discovery | MicrosoftTeams | MicrosoftTeamsAddOns | MicrosoftTeamsSettingsOperation | ThreatIntelligence AeD, MicrosoftStream, ThreatFinder, Project, SharePointListOperation, DataGovernance, SecurityComplianceAlerts, ThreatIntelligenceUrl, SecurityComplianceInsights, WorkplaceAnalytics, PowerAppsApp, PowerAppsPlan, ThreatIntelligenceAtpContent, LabelExplorer, TeamsHealthcare, ExchangeItemAggregated, HygieneEvent>
	 #>
	
	$scriptStart=(get-date)

	$sessionName = (get-date -Format 'u')+'o365auditlog'
	# Reset user audit accumulator
	$aggregateResults = @()
	$i = 0 # Loop counter
	Do { 
		Write-host " -----------------------------------------" -ForegroundColor Yellow
		if($specifyPeriod -eq $true)
		{
			if($specifyUserIDs -eq $true)
			{
				if ($specifyRecordTypes -eq $true)
				{
					Write-host "  >> Audit Request Details: StartDate=", $startDate, "- EndDate=", $endDate, "- SpecifiedUserIDs=", $SpecifiedUserIDs, "- RecordType=", $RecordTypeValues -ForegroundColor Magenta
					$currentResults = Search-UnifiedAuditLog -StartDate $startDate -EndDate $enddate -SessionId $sessionName -SessionCommand ReturnLargeSet -ResultSize 1000 -UserIds $SpecifiedUserIDs -RecordType $RecordTypeValues
				}
				else
				{
					Write-host "  >> Audit Request Details: StartDate=", $startDate, "- EndDate=", $endDate, "- SpecifiedUserIDs=", $SpecifiedUserIDs -ForegroundColor Magenta
					$currentResults = Search-UnifiedAuditLog -StartDate $startDate -EndDate $enddate -SessionId $sessionName -SessionCommand ReturnLargeSet -ResultSize 1000 -UserIds $SpecifiedUserIDs
				}
			}
			else
			{
				if ($specifyRecordTypes -eq $true)
				{
					Write-host "  >> Audit Request Details: StartDate=", $startDate, "- EndDate=", $endDate, "- RecordType=", $RecordTypeValues -ForegroundColor Magenta
					$currentResults = Search-UnifiedAuditLog -StartDate $startDate -EndDate $enddate -SessionId $sessionName -SessionCommand ReturnLargeSet -ResultSize 1000 -RecordType $RecordTypeValues
				}
				else
				{
					Write-host "  >> Audit Request Details: StartDate=", $startDate, "- EndDate=", $endDate -ForegroundColor Magenta
					$currentResults = Search-UnifiedAuditLog -StartDate $startDate -EndDate $enddate -SessionId $sessionName -SessionCommand ReturnLargeSet -ResultSize 1000
				}
			}
		}
		else
		{
			$enddate = get-date
			$startDate = $enddate.AddDays($DefaultPeriodToCheck) #default period is the last week
			if($specifyUserIDs -eq $true)
			{
				if ($specifyRecordTypes -eq $true)
				{
					Write-host "  >> Audit Request Details: StartDate=", $startDate, "- EndDate=", $endDate, "- SpecifiedUserIDs=", $SpecifiedUserIDs, "- RecordType=", $RecordTypeValues -ForegroundColor Magenta
					$currentResults = Search-UnifiedAuditLog -StartDate $startDate -EndDate $enddate -SessionId $sessionName -SessionCommand ReturnLargeSet -ResultSize 1000 -UserIds $SpecifiedUserIDs -RecordType $RecordTypeValues
				}
				else
				{
					Write-host "  >> Audit Request Details: StartDate=", $startDate, "- EndDate=", $endDate, "- SpecifiedUserIDs=", $SpecifiedUserIDs -ForegroundColor Magenta
					$currentResults = Search-UnifiedAuditLog -StartDate $startDate -EndDate $enddate -SessionId $sessionName -SessionCommand ReturnLargeSet -ResultSize 1000 -UserIds $SpecifiedUserIDs
				}
			}
			else
			{
				if ($specifyRecordTypes -eq $true)
				{
					Write-host "  >> Audit Request Details: StartDate=", $startDate, "- EndDate=", $endDate, "- RecordType=", $RecordTypeValues -ForegroundColor Magenta
					$currentResults = Search-UnifiedAuditLog -StartDate $startDate -EndDate $enddate -SessionId $sessionName -SessionCommand ReturnLargeSet -ResultSize 1000 -RecordType $RecordTypeValues
				}
				else
				{
					Write-host "  >> Audit Request Details: StartDate=", $startDate, "- EndDate=", $endDate -ForegroundColor Magenta
					$currentResults = Search-UnifiedAuditLog -StartDate $startDate -EndDate $enddate -SessionId $sessionName -SessionCommand ReturnLargeSet -ResultSize 1000
				}
			
			}
		}
		
		if ($currentResults.Count -gt 0)
		{
			Write-Host ("  Finished {3} search #{1}, {2} records: {0} min" -f [math]::Round((New-TimeSpan -Start $scriptStart).TotalMinutes,4), $i, $currentResults.Count, $user.UserPrincipalName )
			# Accumulate the data
			$aggregateResults += $currentResults
			# No need to do another query if the # recs returned <1k - should save around 5-10 sec per user
			if ($currentResults.Count -lt 1000)
			{
				$currentResults = @()
			}
			else
			{
				$i++
			}
		}
	} Until ($currentResults.Count -eq 0) # --- End of Session Search Loop --- #
	
	[int]$IntemIndex = 1
	$GLOBAL:data=@()
    foreach ($line in $aggregateResults)
    {
		Write-host "  ItemIndex:", $IntemIndex, "- Creation Date:", $line.CreationDate, "- UserIds:", $line.UserIds, "- Operations:", $line.Operations
		#Write-host "      > AuditData:", $line.AuditData
		$datum = New-Object -TypeName PSObject
		try
		{
			$Converteddata = convertfrom-json $line.AuditData
		
			$datum | Add-Member -MemberType NoteProperty -Name Id -Value $Converteddata.Id
			$datum | Add-Member -MemberType NoteProperty -Name CreationTimeUTC -Value $Converteddata.CreationTime
			$datum | Add-Member -MemberType NoteProperty -Name CreationTime -Value $line.CreationDate
			$datum | Add-Member -MemberType NoteProperty -Name Operation -Value $Converteddata.Operation
			$datum | Add-Member -MemberType NoteProperty -Name OrganizationId -Value $Converteddata.OrganizationId
			$datum | Add-Member -MemberType NoteProperty -Name RecordType -Value $Converteddata.RecordType
			$datum | Add-Member -MemberType NoteProperty -Name ResultStatus -Value $Converteddata.ResultStatus
			$datum | Add-Member -MemberType NoteProperty -Name UserKey -Value $Converteddata.UserKey
			$datum | Add-Member -MemberType NoteProperty -Name UserType -Value $Converteddata.UserType
			$datum | Add-Member -MemberType NoteProperty -Name Version -Value $Converteddata.Version
			$datum | Add-Member -MemberType NoteProperty -Name Workload -Value $Converteddata.Workload
			$datum | Add-Member -MemberType NoteProperty -Name UserId -Value $Converteddata.UserId
			$datum | Add-Member -MemberType NoteProperty -Name ClientIPAddress -Value $Converteddata.ClientIPAddress
			$datum | Add-Member -MemberType NoteProperty -Name ClientInfoString -Value $Converteddata.ClientInfoString
			$datum | Add-Member -MemberType NoteProperty -Name ClientProcessName -Value $Converteddata.ClientProcessName
			$datum | Add-Member -MemberType NoteProperty -Name ClientVersion -Value $Converteddata.ClientVersion
			$datum | Add-Member -MemberType NoteProperty -Name ExternalAccess -Value $Converteddata.ExternalAccess
			$datum | Add-Member -MemberType NoteProperty -Name InternalLogonType -Value $Converteddata.InternalLogonType
			$datum | Add-Member -MemberType NoteProperty -Name LogonType -Value $Converteddata.LogonType
			$datum | Add-Member -MemberType NoteProperty -Name LogonUserSid -Value $Converteddata.LogonUserSid
			$datum | Add-Member -MemberType NoteProperty -Name MailboxGuid -Value $Converteddata.MailboxGuid
			$datum | Add-Member -MemberType NoteProperty -Name MailboxOwnerSid -Value $Converteddata.MailboxOwnerSid
			$datum | Add-Member -MemberType NoteProperty -Name MailboxOwnerUPN -Value $Converteddata.MailboxOwnerUPN
			$datum | Add-Member -MemberType NoteProperty -Name OrganizationName -Value $Converteddata.OrganizationName
			$datum | Add-Member -MemberType NoteProperty -Name OriginatingServer -Value $Converteddata.OriginatingServer
			$datum | Add-Member -MemberType NoteProperty -Name SessionId -Value $Converteddata.SessionId
			$datum | Add-Member -MemberType NoteProperty -Name LogonError -Value $Converteddata.LogonError
			$datum | Add-Member -MemberType NoteProperty -Name Subject -Value $Converteddata.Subject
			$datum | Add-Member -MemberType NoteProperty -Name ObjectId -Value $Converteddata.ObjectId
			$datum | Add-Member -MemberType NoteProperty -Name SiteUrl -Value $Converteddata.SiteUrl
			$datum | Add-Member -MemberType NoteProperty -Name SourceRelativeUrl -Value $Converteddata.SourceRelativeUrl
			$datum | Add-Member -MemberType NoteProperty -Name AuditDataRaw -Value $line.AuditData
		}
		catch
		{
			Write-host "  =====>>>> JSON FORMAT NOT CORRECT " -ForegroundColor Red
			Write-host "  =====>>>> AuditData:", $line.AuditData  -ForegroundColor Yellow
			[guid]$NewGuid = [guid]::newguid()			
			$datum | Add-Member -MemberType NoteProperty -Name Id -Value $NewGuid
			$datum | Add-Member -MemberType NoteProperty -Name CreationTimeUTC -Value $line.CreationDate
			$datum | Add-Member -MemberType NoteProperty -Name CreationTime -Value $line.CreationDate
			$datum | Add-Member -MemberType NoteProperty -Name UserId -Value $line.UserIds
			$datum | Add-Member -MemberType NoteProperty -Name Operation -Value $line.Operations
			$datum | Add-Member -MemberType NoteProperty -Name AuditDataRaw -Value $line.AuditData
		}
	
		$GLOBAL:data += $datum
		$IntemIndex += 1
	}


IF (!(Test-Path -Path "$DesktopPath\MS-Logs\Unified_Audit_Logs_$ts")) {
$ts = Get-Date -Format yyyyMMdd_hhmmss
$DesktopPath = ([Environment]::GetFolderPath('Desktop'))
$logsPATH = mkdir "$DesktopPath\MS-Logs\Unified_Audit_Logs_$ts" }

$fileName = ( "$logsPATH" +"\Unified_Audit_Logs_$ts" + ".csv")
	
	Write-host " -----------------------------------------" -ForegroundColor Green
	Write-Host (" >>> writing to file {0}" -f $fileName) -ForegroundColor Green

try { $GLOBAL:data | Export-csv $fileName -Force -NoTypeInformation -ErrorAction Stop } 
catch { $GLOBAL:data | Export-csv "C:\Unified_Audit_Logs_$(Get-Date -Format yyyyMMdd_hhmmss).CSV" -NoTypeInformation  }
	Write-host " -----------------------------------------" -ForegroundColor Green

Stop-Transcript
#$error | Export-Clixml -Depth 4 "$logsPATH\Error-$ts.XML"
Compress-Archive -Path $logsPATH -DestinationPath "$DesktopPath\MS-Logs\Unified_Audit_Logs_$ts" # Zip Logs
Invoke-Item $DesktopPath\MS-Logs           # open Logs Folder in file manager
###### END ZIP Logs ########################

###### Error XML - ONLY if necessary #######
#$error | Export-Clixml -Depth 4 "$DesktopPath\MS-Logs\Errors-$ts.XML"

	#Remove-PSSession $Session
}
cls
Split-O365AuditLogs-FromO365