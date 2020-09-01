
# old - lines glues with apostroph
WITHOUT  ResourceDelegates 

$mailbox = “mailbox@domain.com”

set-calendarprocessing -identity $mailbox `
-AutomateProcessing Autoaccept `
-AllowConflicts $false `
-AllRequestOutOfPolicy $false `
-DeleteSubject $false `
-AddOrganizerToSubject $true `
-ForwardRequestsToDelegates $false `
-AllRequestInPolicy $false `
-AllBookInPolicy $true `
-ResourceDelegates $Null


vs WITH  ResourceDelegates

$mailbox = “mailbox@domain.com”
$resourcedelegates = "chris@contoso.com","michelle@contoso.com"
set-calendarprocessing -identity $mailbox `
-AutomateProcessing AutoUpdate `
-AllowConflicts $false `
-AllRequestOutOfPolicy $false `
-DeleteSubject $false `
-AddOrganizerToSubject $true `
-ForwardRequestsToDelegates $true `
-AllRequestInPolicy $true `
-AllBookInPolicy $false `
-ResourceDelegates $resourcedelegates

############################
#                          #
#  new as parameter array  #
#                          #
############################

$mailbox = “mailbox@domain.com”
$resourcedelegates = "chris@contoso.com","michelle@contoso.com"

$with = @{ identity = $mailbox; 
AutomateProcessing = 'AutoUpdate';
AllowConflicts = $false;
AllRequestOutOfPolicy = $false;
DeleteSubject = $false;
AddOrganizerToSubject = $true;
ForwardRequestsToDelegates = $true;
AllRequestInPolicy = $true;
AllBookInPolicy = $false;
ResourceDelegates = $resourcedelegates; }
set-calendarprocessing @with 


$mailbox = “mailbox@domain.com”
$without = @{ identity = $mailbox;
AutomateProcessing = 'Autoaccept';
AllowConflicts = $false;
AllRequestOutOfPolicy = $false;
DeleteSubject = $false;
AddOrganizerToSubject = $true;
ForwardRequestsToDelegates = $false;
AllRequestInPolicy = $false;
AllBookInPolicy = $true;
ResourceDelegates = $Null;}

set-calendarprocessing @without
