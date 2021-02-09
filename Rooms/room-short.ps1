
# Version (1) WITHDelegates


#### start ###
$mailbox = “mailbox@domain.com”
$resourcedelegates = "chris@contoso.com","michelle@contoso.com"

$WITHDelegates = @{ identity = $mailbox; 
AutomateProcessing = 'AutoUpdate';
AllowConflicts = $false;
AllRequestOutOfPolicy = $false;
DeleteSubject = $false;
AddOrganizerToSubject = $true;
ForwardRequestsToDelegates = $true;
AllRequestInPolicy = $true;
AllBookInPolicy = $false;
ResourceDelegates = $resourcedelegates; }
set-calendarprocessing @WITHDelegates 
#### end ###


# Version (2) WITHOUTDelegates 

#### start ###
$mailbox = “mailbox@domain.com”

$WITHOUTDelegates = @{ identity = $mailbox;
AutomateProcessing = 'Autoaccept';
AllowConflicts = $false;
AllRequestOutOfPolicy = $false;
DeleteSubject = $false;
AddOrganizerToSubject = $true;
ForwardRequestsToDelegates = $false;
AllRequestInPolicy = $false;
AllBookInPolicy = $true;
ResourceDelegates = $Null;}

set-calendarprocessing @WITHOUTDelegates
#### end ###