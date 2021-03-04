########### Reference ###################################################################################
# https://docs.microsoft.com/en-us/microsoft-365/security/office-365-security/external-email-forwarding #
#########################################################################################################

######### Tenant Level ##################################################################################

Get-HostedOutboundSpamFilterPolicy | Set-HostedOutboundSpamFilterPolicy -AutoForwardingMode on

######### User Level ####################################################################################
#    IF you scope ANOTHER policy on a USER, only the scoped policy will be applied for that user        #
#########################################################################################################

NEW-HostedOutboundSpamFilterPolicy "AutoForward" -AutoForwardingMode on

New-HostedOutboundSpamFilterRule -Name "AutoForward rule" -HostedOutboundSpamFilterPolicy "AutoForward" -FromMemberOf "AutoForward security group"