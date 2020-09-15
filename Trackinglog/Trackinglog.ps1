Get-TransportService | Get-MessageTrackingLog -Start (get-date).AddDays(-15) -End (get-date) -sender “affected@sender.com" | Export-CsV C:\Temp\sendertrackinglog1.csv

Get-TransportService | Get-MessageTrackingLog -Start (get-date).AddDays(-15) -End (get-date) -sender “affected@recipient.com" | Export-CsV C:\Temp\receivetrackinglog1.csv 

# if it has any issues, then without the pipeline

Get-MessageTrackingLog -Start (get-date).AddDays(-15) -End (get-date) -sender “affected@sender.com" | Export-CsV C:\Temp\sendertrackinglog2.csv

Get-MessageTrackingLog -Start (get-date).AddDays(-15) -End (get-date) -Recipients “affected@recipient.com" | Export-CsV C:\Temp\receivetrackinglog2.csv