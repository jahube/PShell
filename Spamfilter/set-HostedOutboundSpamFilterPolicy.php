Get-HostedOutboundSpamFilterPolicy | Set-HostedOutboundSpamFilterPolicy -AutoForwardingMode on

# the Default is applied only if a specific is not applied
# if you scope on a user, only that policy will apply for the user

NEW-HostedOutboundSpamFilterPolicy "AutoForward" -AutoForwardingMode on

New-HostedOutboundSpamFilterRule -Name "AutoForward rule" -HostedOutboundSpamFilterPolicy "AutoForward" -FromMemberOf "AutoForward security group"