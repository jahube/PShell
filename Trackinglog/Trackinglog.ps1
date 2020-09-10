Get-TransportService | Get-MessageTrackingLog -Start (get-date).AddDays(-15) -End (get-date) -sender “affected@sender.com" | Export-CsV C:\Temp\trackinglog.csv

 # if it has any issues, then without the pipeline

Get-MessageTrackingLog -Start (get-date).AddDays(-15) -End (get-date) -sender “affected@sender.com" | Export-CsV C:\Temp\trackinglog.csv