@(get-unifiedgroup)[0] | % { Get-TeamChannel -GroupId $_.ExternalDirectoryObjectId  }

$data = @()
foreach ($G in $Groups) { 
$item = New-Object -TypeName PSObject   
$item | Add-Member -MemberType NoteProperty -Name Type -Value "Group"
$item | Add-Member -MemberType NoteProperty -Name DisplayName -Value $G.DisplayName
$item | Add-Member -MemberType NoteProperty -Name ExternalDirectoryObjectId -Value $G.ExternalDirectoryObjectId
$item | Add-Member -MemberType NoteProperty -Name Name -Value $G.Name
$item | Add-Member -MemberType NoteProperty -Name Alias -Value $G.Alias
$item | Add-Member -MemberType NoteProperty -Name PrimarySMTP -Value $G.PrimarySMTP
#MBX
Try { $MBX = @() ; $MBX = Get-Mailbox $G.ExternalDirectoryObjectId -GroupMailbox -ErrorAction stop } catch { write-host $Error[0].Exception.message -F yellow } 
IF ($MBX) { $item | Add-Member -MemberType NoteProperty -Name MBXSMTP -Value $MBX.PrimarySMTP
            $item | Add-Member -MemberType NoteProperty -Name MBXAlias -Value $MBX.Alias }
$data += $item
#Team
Try { $teams = Get-Team -GroupId $G.ExternalDirectoryObjectId |fl -ErrorAction stop 
} catch { write-host $Error[0].Exception.message -F yellow }
IF ($teams) { foreach ($T in $teams) {
Try { $channel = Get-TeamChannel -GroupId $T.GroupId -ErrorAction stop } catch { write-host $Error[0].Exception.message -F yellow }
If ($channel) {
$item = New-Object -TypeName PSObject 
$item | Add-Member -MemberType NoteProperty -Name Type -Value "Channel"      
$item | Add-Member -MemberType NoteProperty -Name DisplayName -Value $G.DisplayName
$item | Add-Member -MemberType NoteProperty -Name ExternalDirectoryObjectId -Value $G.ExternalDirectoryObjectId
$item | Add-Member -MemberType NoteProperty -Name Alias -Value $G.Alias
$item | Add-Member -MemberType NoteProperty -Name PrimarySMTP -Value $G.PrimarySMTP
 }
$item = New-Object -TypeName PSObject       
$item | Add-Member -MemberType NoteProperty -Name searchdate -Value $cal
$data += $item
} }
$teams[0] | fl *

Get-TeamChannel -GroupId $teams[0].GroupId 
Get-TeamChanneluser -GroupId ff375450-6165-40aa-a96c-ccba77ad35a3 -DisplayName general | Get-Member
 DebraB@edu.dnsabr.com
 (get-mailbox -GroupMailbox).count | FT
 (Get-UnifiedGroup).count | FT
 Get-Team
  (Get-Team).count | FT
$channel | % { Get-TeamChanneluser -GroupId $_.ExternalDirectoryObjectId -DisplayName $_.DisplayName }
Get-TeamChannelUser -GroupId
$channel | fl *
get-unifiedgroup | % { Get-TeamChannelUSER - -GroupId $_.ExternalDirectoryObjectId  }
get-unifiedgroup | Get-TeamChannel | Get-TeamChannelUSER
Get-TeamChannel
Install-Module MicrosoftTeams -AllowPrerelease
         @(GET-MODULE MicrosoftTeams -LISTAVAILABLE | Sort-Object VERSION -Descending)[0].VERSION
Install-Module MicrosoftTeams -AllowPrerelease -RequiredVersion "1.1.10-preview"
IMPORT-Module MicrosoftTeams -MinimumVersion 1.1.10
Connect-MicrosoftTeams -Credential $cred
Install-Module MicrosoftTeams -AllowPrerelease -RequiredVersion $((GET-MODULE MicrosoftTeams -LISTAVAILABLE | Sort-Object VERSION -Descending)[0]).Version.ToString() -Repository PsTestGallery
Remove-Module MicrosoftTeams -Force
Uninstall-Module MicrosoftTeams -MaximumVersion $((GET-MODULE MicrosoftTeams -LISTAVAILABLE | Sort-Object VERSION -Descending)[1]).Version.ToString() -Force
Get-PSSession | Remove-PSSession

437778d6.M365EDU471782.onmicrosoft.com@emea.teams.ms>
Get-TeamUser -GroupId 2f162b0e-36d2-4e15-8ba3-ba229cecdccf -Role Owner



    
    
      @(get-unifiedgroup)[0] | % {​ Get-TeamChannel -GroupId $_.ExternalDirectoryObjectId  }​
get-unifiedgroup | % {​ Get-TeamChannel -GroupId $_.ExternalDirectoryObjectId  }​
get-unifiedgroup | % {​ Get-TeamChannelUSER -GroupId $_.ExternalDirectoryObjectId  }​
Install-Module MicrosoftTeams -AllowPrerelease
         @(GET-MODULE MicrosoftTeams -LISTAVAILABLE | Sort-Object VERSION -Descending)[0].VERSION
Install-Module MicrosoftTeams -AllowPrerelease -RequiredVersion "1.1.10-preview"
IMPORT-Module MicrosoftTeams -MinimumVersion 1.1.10
Connect-MicrosoftTeams -Credential $cred
Install-Module MicrosoftTeams -AllowPrerelease -RequiredVersion $((GET-MODULE MicrosoftTeams -LISTAVAILABLE | Sort-Object VERSION -Descending)[0]).Version.ToString() -Repository PsTestGallery
Uninstall-Module MicrosoftTeams -MaximumVersion $((GET-MODULE MicrosoftTeams -LISTAVAILABLE | Sort-Object VERSION -Descending)[1]).Version.ToString() -Force
Get-PSSession | Remove-PSSession
    
    
  
  

