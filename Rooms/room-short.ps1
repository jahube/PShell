# Reference https://support.microsoft.com/en-us/topic/resources-in-exchange-don-t-respond-to-meeting-requests-e6d24af5-36ae-5d87-b615-f292f3953dac

# check [ressource booking assistant] if [AutomateProcessing] is conflicting with [ResourceDelegates]/[ForwardRequestsToDelegates]

# below are 2 "best practive" configurations

# Version (1) >> WITH Delegates <<

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


# Version (2) >> WITHOUT Delegates <<

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