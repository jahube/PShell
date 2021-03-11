########### Release Short ###################### Onliner ############################################################################################
# Release-QuarantineMessage -Identity 000 -Identities @(Get-QuarantineMessage | Select-Object *ss,Me*,*ity | OGV -P -T "RELEASE").identity -Rel -F  #
############## Export short #########################################################################################################################
# $MSG = Export-QuarantineMessage -Identity 000 -Identities @(Get-QuarantineMessage | Select-Object *ss,Me*,*ity | OGV -P -T "EXPORT").identity     #
# Foreach ($M in $MSG) { [IO.File]::WriteAllBytes([String]$("C:\TempQ\"+$M.Identity.Split('\')[1]+".eml"), $([Convert]::FromBase64String($m.Eml)))} #
############ Long Version ###########################################################################################################################

$ts = Get-Date -Format yyyyMMdd_hhmmss

IF(!@(Get-PSSession | where { $_.State -ne "broken" } ) ) { 
Try { Connect-ExchangeOnline } catch { install-module ExchangeOnlinemanagement ; Connect-ExchangeOnline} }

                      $FormatEnumerationLimit = -1
       $DesktopPath = ([Environment]::GetFolderPath('Desktop'))
  [String]$logsPATH = mkdir "$DesktopPath\MS-Logs\$ts\MS-Logs_Headers"
  [String]$MailPATH = mkdir "$DesktopPath\MS-Logs\$ts\QuarantineMessages”

    Start-Transcript -Path $logsPATH\Transcript_$ts.txt

  $MSrch = Get-QuarantineMessage

 $Filter = $MSrch  | Select-Object ReceivedTime,SenderAddress,RecipientAddress,QuarantineTypes,PolicyType,PolicyName,Reported,ReleaseStatus,Expires,MessageId,Identity
 $Sorted = $Filter | Sort-Object ReceivedTime,SenderAddress
$MenuSel = $Sorted | Out-GridView -Title "select Messages to release" -PassThru

 $Sorted | Export-Csv -Path "$logsPATH\All-Quarantine-Messages-before_$ts.CSV" -NoTypeInformation
  $MSrch | Export-Clixml "$logsPATH\All-Quarantine-Messages-before_$ts.XML"
$MenuSel | Export-Csv -Path "$logsPATH\Exp-Quarantine-Messages-$ts.csv" -NoTypeInformation

$count = $MenuSel.count ; $mcount = 0 ;

Foreach ($Message in $MenuSel) { 

$m = $null ; $m = Export-QuarantineMessage -Identity $Message.Identity ; $email = $m.Eml

$MessageId = $null ; $MessageId = $Message.MessageId -Replace "(\<)|(\>)", ""

[string]$MessageIdfirst = $MessageId.Split('@')[0]
[string]$SenderAddress = $Message.SenderAddress -Replace "(\@)", "_" ;
[string]$MessageId = $MessageId -Replace "(\@)", "_" ; 
[string]$NID = $m.Identity.Split('\')[1]
[string]$DateString = get-date $Message.ReceivedTime -Format yyyy-MM-dd_HH.mm ;

#$filePath1 = "$MailPATH" + “\" + "$MessageId" + ".eml”

[string]$PStr =  "$DateString" + "_" +  $SenderAddress + "_" +"$MessageIdfirst" + "_" + "$NID"
[string]$String = $PStr.Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
    IF ($String.length -gt "200") { $String = $String.substring(0, "200") }

[string]$filePath1 = "$MailPATH" + “\" + $String + '.Eml'
[string]$filePath2 = "$MailPATH" + “\" + $String + "_" + “UTF8" + '.Eml'
[string]$filePath3 = "$MailPATH" + “\" + $String + "_" + “Byte" + '.Eml'

if([System.IO.File]::Exists($filePath3) -eq $true) {
$filePath1 = $filePath1.Split('.Eml')[0] + "_" + (Get-Date -Format ss) + '.Eml' }

if([System.IO.File]::Exists($filePath3) -eq $true) {
$filePath2 = $filePath2.Split('.Eml')[0] + "_" + (Get-Date -Format ss) + '.Eml' }

if([System.IO.File]::Exists($filePath3) -eq $true) {
$filePath3 = $filePath3.Split('.Eml')[0] + "_" + (Get-Date -Format ss) + '.Eml' }

$Ttl = "Exporting to Desktop - MS-Logs - [Received] $($DateString) [Sender] $($Message.SenderAddress) [Recipient] $([String]$Message.RecipientAddress)"

IF ($mcount -ne "0") { $Percent = (($mcount/$count)*100)} Else { $Percent = "1" }

Write-Progress -Activity $Ttl -Status "Message: $($Message.MessageId)" -PercentComplete $Percent -SecondsRemaining (($count-$mcount)*5) ;

# Base64 encoding
If ($m.BodyEncoding -match 'Base64' -or $m.BodyEncoding -eq 'Base64') { 
     $FromBase64 = [Convert]::FromBase64String($email)
                   [IO.File]::WriteAllBytes("$filePath3", $FromBase64) }
# UTF8 encoding
ElseIf ($m.BodyEncoding -match 'UTF8' -or $m.BodyEncoding -match 'UTF-8') { $email | Out-File -FilePath "$filePath1" -Encoding UTF8 -Force }

# Ascii encoding
ElseIf ($m.BodyEncoding -match 'UTF'-or $m.BodyEncoding -match 'Ascii' -or $m.BodyEncoding -eq 'Ascii') { 
                        $email | Out-File -FilePath "$filePath1" -Encoding Ascii -Force }
# Binary encoding
Elseif ($m.BodyEncoding -match 'binary' -or $m.BodyEncoding -eq 'binary') { [IO.File]::WriteAllBytes("$filePath3", $email) }

Else { Try {               [IO.File]::WriteAllBytes("$filePath1", $email)      } catch {}

       Try { $FromBase64 = [Convert]::FromBase64String($email)
                           [IO.File]::WriteAllBytes("$filePath3", $FromBase64) } catch {}

       Try {       $UTF8 = [System.Text.Encoding]::Utf8.GetString($email)
                   $UTF8 | Out-File -FilePath "$filePath2" -Encoding UTF8 -Force } catch {} }
# Header
$header = Get-QuarantineMessageHeader –identity $Message.Identity ; $headerpath = “$logsPATH\$MessageId.txt”
if([System.IO.File]::Exists($headerpath) -eq $true) {$headerpath=("$logsPATH\$MessageId" + "_" + (Get-Date -Format mmss) + ".txt")}
$header.Header | Out-File -FilePath $headerpath -Encoding UTF8

Release-QuarantineMessage –identity $Message.Identity -Confirm:$false -ReleaseToAll –Force ; $mcount++ }

# CSV After
$MSrch2 = Get-QuarantineMessage
$MSel2 = $MSrch2 | Select-Object ReceivedTime,SenderAddress,RecipientAddress,QuarantineTypes,PolicyType,PolicyName,Reported,ReleaseStatus,Expires,MessageId,Identity
$MSel2 | Export-Csv -Path "$logsPATH\All-Quarantine-Messages_$ts.csv" -NoTypeInformation

Stop-Transcript

$destination = "$DesktopPath\MS-Logs\$ts" + "\MS-Logs_Headers_$ts.zip"
Add-Type -assembly “system.io.compression.filesystem”
[io.compression.zipfile]::CreateFromDirectory($logsPATH, $destination)
Invoke-Item "$DesktopPath\MS-Logs\$ts" 
