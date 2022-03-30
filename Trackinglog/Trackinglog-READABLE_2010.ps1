
$EMAIL = 'EMAIL@DOMAIN.com'     # Change

#$MessageID = "<MessageID>"      # Change

$timeframe = “-5" # ("days back")

#$VerbosePreference = 'Continue'
$ts = Get-Date -Format yyyyMMdd_hhmmss
#$FormatEnumerationLimit = -1
$DesktopPath = ([Environment]::GetFolderPath('Desktop'))
$logsPATH =mkdir "$DesktopPath\MS-Logs\$ts" # creates MS-Logs on desktop + Timestamp
Start-Transcript "$logsPATH\OnPremises$ts.txt" -Verbose

$Servers=Get-ExchangeServer|where{$_.isHubTransportServer -eq $true};

$senderlog = $Servers | Get-MessageTrackingLog -Start (get-date).AddDays($timeframe) -End (get-date) -sender $EMAIL 
$senderlog | Export-CsV "$logsPATH\Sender-trackinglog.csv" -Encoding UTF8 -Delimiter ";" -Force -NoTypeInformation
$senderlog | Export-clixml -path "$logsPATH\Sender-trackinglog.xml"


$Recipientlog = $Servers | Get-MessageTrackingLog -Start (get-date).AddDays($timeframe) -End (get-date) -Recipients $EMAIL 
$Recipientlog | Export-CsV "$logsPATH\Receive-trackinglog.csv" -Encoding UTF8 -Delimiter ";" -Force -NoTypeInformation
$Recipientlog | Export-clixml -path "$logsPATH\Receive-trackinglog.xml"


#$MessageIDLog = $Servers | Get-MessageTrackingLog -MessageId $MessageID
#$MessageIDLog | Export-CsV "$logsPATH\MessageID-trackinglog.csv" -Encoding UTF8 -Delimiter ";" -Force -NoTypeInformation
#$MessageIDLog | Export-clixml -path "$logsPATH\MessageID-trackinglog.xml"

$queue = $Servers | % { Get-queue -server $_.name } ; $queue.LastError

Get-RemoteDomain |ft DomainName,IsInternal,TargetDeliveryDomain,TrustedMail*,OriginatingServer

#Foreach ($i in (Get-ExchangeServer)) {Write-Host $i.FQDN; Get-ExchangeCertificate -Server $i.Identity }
#Foreach ($c in (Get-ExchangeCertificate)) {Write-Host $c.Thumbprint; Get-ExchangeCertificate -Thumbprint $c.Thumbprint | fl}

# convert to Readable CSV Format properties
Function HashConvertTo-String($ht) { $first = $true ;
  foreach($pair in $ht.GetEnumerator()) {
    if ($first) { $first = $false } else { $output += ';' }
    $output+=" {0} = {1}" -f $($pair.key),$($pair.Value)  }
   $output }

$senderlog_Fixed = $senderlog | select Timestamp,ClientIp,ClientHostname,ServerIp,ServerHostname,SourceContext,ConnectorId,Source,EventId,InternalMessageId,MessageId,NetworkMessageId,@{ n = 'Recipients'; e = {  (($_ | select -expandproperty Recipients) -join " | ") | Out-String }},@{ n = 'RecipientStatus'; e = { $(($_ | select -expandproperty RecipientStatus) -join " | ") | Out-String }},MessageSubject,Sender,ReturnPath,Directionality,TenantId,OriginalClientIp,MessageInfo,MessageLatency,MessageLatencyType,@{ n = "EventData" ; e = {  $(($_ | select -expandproperty EventData) -join " | ") | Out-String }},TransportTrafficType
$senderlog_Fixed | Export-Csv "$path\Sender-trackinglog-READABLE-Properties.CSV" -Encoding UTF8 -Delimiter ";" -Force -NoTypeInformation

$Recipientlog_Fixed = $Recipientlog | select Timestamp,ClientIp,ClientHostname,ServerIp,ServerHostname,SourceContext,ConnectorId,Source,EventId,InternalMessageId,MessageId,NetworkMessageId,@{ n = 'Recipients'; e = {  (($_ | select -expandproperty Recipients) -join " | ") | Out-String }},@{ n = 'RecipientStatus'; e = { $(($_ | select -expandproperty RecipientStatus) -join " | ") | Out-String }},MessageSubject,Sender,ReturnPath,Directionality,TenantId,OriginalClientIp,MessageInfo,MessageLatency,MessageLatencyType,@{ n = "EventData" ; e = {$(($_ | select -expandproperty EventData) -join " | ") | Out-String }},TransportTrafficType
$Recipientlog_Fixed | Export-Csv "$path\Receive-trackinglog-READABLE-Properties.CSV" -Encoding UTF8 -Delimiter ";" -Force -NoTypeInformation

<#
$MessageIDLog_Fixed = $MessageIDLog | select Timestamp,ClientIp,ClientHostname,ServerIp,ServerHostname,SourceContext,ConnectorId,Source,EventId,InternalMessageId,MessageId,NetworkMessageId,@{ n = 'Recipients'; e = { "$({$_.Recipients})" }},@{ n = 'RecipientStatus'; e = { $_.RecipientStatus | Out-String }},MessageSubject,Sender,ReturnPath,Directionality,TenantId,OriginalClientIp,MessageInfo,MessageLatency,MessageLatencyType,@{ n = "EventData" ; e = { ($_.EventData |% { "$($_.key): $($_.value) ;"}) -join "|" }},TransportTrafficType
$MessageIDLog_Fixed | Export-Csv "$path\MessageID-trackinglog-READABLE-Properties.CSV" -Force
#>

Stop-transcript
######END SCRIPT ##########################
# Logs >> Zip file
#$destination = "$DesktopPath\MS-Logs\ConnectorLogs_$ts.zip"
#Add-Type -assembly “system.io.compression.filesystem”
#[io.compression.zipfile]::CreateFromDirectory($logsPATH, $destination) # ZIP
Invoke-Item $DesktopPath\MS-Logs # open file manager

<#
$senderlog_Fixed = $senderlog | select Timestamp,ClientIp,ClientHostname,ServerIp,ServerHostname,SourceContext,ConnectorId,Source,EventId,InternalMessageId,MessageId,NetworkMessageId,{$_.Recipients},{ $_.RecipientStatus},MessageSubject,Sender,ReturnPath,Directionality,TenantId,OriginalClientIp,MessageInfo,MessageLatency,MessageLatencyType,{ $_.EventData },TransportTrafficType
$senderlog_Fixed | Export-Csv "$path\Sender-trackinglog-READABLE-Properties.CSV" -Encoding UTF8 -Delimiter ";" -Force -NoTypeInformation

$Recipientlog_Fixed = $Recipientlog |  select Timestamp,ClientIp,ClientHostname,ServerIp,ServerHostname,SourceContext,ConnectorId,Source,EventId,InternalMessageId,MessageId,NetworkMessageId,{$_.Recipients},{ $_.RecipientStatus},MessageSubject,Sender,ReturnPath,Directionality,TenantId,OriginalClientIp,MessageInfo,MessageLatency,MessageLatencyType,{ $_.EventData },TransportTrafficType
$Recipientlog_Fixed | Export-Csv "$path\Receive-trackinglog-READABLE-Properties.CSV" -Encoding UTF8 -Delimiter ";" -Force -NoTypeInformation


$senderlog_Fixed = $senderlog | select Timestamp,ClientIp,ClientHostname,ServerIp,ServerHostname,SourceContext,ConnectorId,Source,EventId,InternalMessageId,MessageId,NetworkMessageId,{$_.Recipients},{ $_.RecipientStatus},MessageSubject,Sender,ReturnPath,Directionality,TenantId,OriginalClientIp,MessageInfo,MessageLatency,MessageLatencyType,{ $_.EventData },TransportTrafficType
$senderlog_Fixed | Export-Csv "$path\Sender-trackinglog-READABLE-Properties.CSV" -Encoding UTF8 -Delimiter ";" -Force -NoTypeInformation

$Recipientlog_Fixed = $Recipientlog |  select Timestamp,ClientIp,ClientHostname,ServerIp,ServerHostname,SourceContext,ConnectorId,Source,EventId,InternalMessageId,MessageId,NetworkMessageId,{$_.Recipients},{ $_.RecipientStatus},MessageSubject,Sender,ReturnPath,Directionality,TenantId,OriginalClientIp,MessageInfo,MessageLatency,MessageLatencyType,{ $_.EventData },TransportTrafficType
$Recipientlog_Fixed | Export-Csv "$path\Receive-trackinglog-READABLE-Properties.CSV" -Encoding UTF8 -Delimiter ";" -Force -NoTypeInformation


[string]::join(";",($_.vvvvv))

$senderlog_Fixed = $senderlog | select Timestamp,ClientIp,ClientHostname,ServerIp,ServerHostname,SourceContext,ConnectorId,Source,EventId,InternalMessageId,MessageId,NetworkMessageId,@{ n = 'Recipients'; e = { [string]::join("|",($_.Recipients)) }},@{ n = 'RecipientStatus'; e = { [string]::join("|",($_.RecipientStatus)) }},MessageSubject,Sender,ReturnPath,Directionality,TenantId,OriginalClientIp,MessageInfo,MessageLatency,MessageLatencyType,@{ n = "EventData" ; e = {   [string]::join("|",($_.EventData)) }},TransportTrafficType
$senderlog_Fixed | Export-Csv "$path\Sender-trackinglog-READABLE-Properties.CSV" -Encoding UTF8 -Delimiter ";" -Force -NoTypeInformation

$Recipientlog_Fixed = $Recipientlog | select Timestamp,ClientIp,ClientHostname,ServerIp,ServerHostname,SourceContext,ConnectorId,Source,EventId,InternalMessageId,MessageId,NetworkMessageId,@{ n = 'Recipients'; e = { [string]::join("|",($_.Recipients)) }},@{ n = 'RecipientStatus'; e = { [string]::join("|",($_.RecipientStatus)) }},MessageSubject,Sender,ReturnPath,Directionality,TenantId,OriginalClientIp,MessageInfo,MessageLatency,MessageLatencyType,@{ n = "EventData" ; e = {  [string]::join("|",($_.EventData)) }},TransportTrafficType
$Recipientlog_Fixed | Export-Csv "$path\Receive-trackinglog-READABLE-Properties.CSV" -Encoding UTF8 -Delimiter ";" -Force -NoTypeInformation


$senderlog_Fixed = $senderlog | select Timestamp,ClientIp,ClientHostname,ServerIp,ServerHostname,SourceContext,ConnectorId,Source,EventId,InternalMessageId,MessageId,NetworkMessageId,@{ n = 'Recipients'; e = { "$({$_.Recipients}  -join " | ")" |out-string }},@{ n = 'RecipientStatus'; e = { $_.RecipientStatus | Out-String }},MessageSubject,Sender,ReturnPath,Directionality,TenantId,OriginalClientIp,MessageInfo,MessageLatency,MessageLatencyType,@{ n = "EventData" ; e = {  (($_.EventData |% { "$($_.key): $($_.value) ;"}) -join "|") | out-string }},TransportTrafficType
$senderlog_Fixed | Export-Csv "$path\Sender-trackinglog-READABLE-Properties.CSV" -Encoding UTF8 -Delimiter ";" -Force -NoTypeInformation

$Recipientlog_Fixed = $Recipientlog | select Timestamp,ClientIp,ClientHostname,ServerIp,ServerHostname,SourceContext,ConnectorId,Source,EventId,InternalMessageId,MessageId,NetworkMessageId,@{ n = 'Recipients'; e = { "$({$_.Recipients}  -join " | ")" |out-string }},@{ n = 'RecipientStatus'; e = { $_.RecipientStatus | Out-String }},MessageSubject,Sender,ReturnPath,Directionality,TenantId,OriginalClientIp,MessageInfo,MessageLatency,MessageLatencyType,@{ n = "EventData" ; e = { (($_.EventData |% { "$($_.key): $($_.value) ;"}) -join "|") | out-string }},TransportTrafficType
$Recipientlog_Fixed | Export-Csv "$path\Receive-trackinglog-READABLE-Properties.CSV" -Encoding UTF8 -Delimiter ";" -Force -NoTypeInformation
#>
