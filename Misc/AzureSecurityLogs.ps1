Get-AzureADAuditDirectoryLogs | select Id, OperationType, ActivityDateTime, Category, Result, ResultReason, ActivityDisplayName, InitiatedBy, LoggedByService, `
@{ n = "TargetResources"; e = { $_.TargetResources.DisplayName } }, @{ n = "Details"; e = { $( $_.AdditionalDetails[0].key + ': ' + $_.AdditionalDetails[0].Value ) } },`
@{ n = "TargetResource_ID"; e = { $_.TargetResources.id } },@{ n = "TargetResource_UPN"; e = { $_.TargetResources.UserPrincipalName } },`
@{ n = "ModifiedProperties"; e = { $_.TargetResources.ModifiedProperties.DisplayName } },@{ n = "OldValue"; e = { $_.TargetResources.ModifiedProperties.OldValue } },`
@{ n = "NewValue"; e = { $_.TargetResources.ModifiedProperties.NewValue } } | Export-Csv "C:\securitylogs.csv" -Force