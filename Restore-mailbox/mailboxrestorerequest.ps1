#statistics

get-mailbox -SoftDeletedMailbox | Get-MailboxFolderStatistics -IncludeSoftDeletedRecipients | ft *name*,*items*

# old syntax

$source = "SOURCE@DOMAIN.com"
$target = "TARGET@DOMAIN.com"

$MBX = (Get-Mailbox -SoftDeletedMailbox $source).DistinguishedName
$TGT = (Get-Mailbox $target).DistinguishedName
New-MailboxRestoreRequest -SourceMailbox $MBX.DistinguishedName -TargetMailbox $TGT.SamAccountName -AllowLegacyDNMismatch

################################################

# new syntax

        $source = "SOURCE@DOMAIN.com"
        $target = "TARGET@DOMAIN.com"

         $param = @{ AllowLegacyDNMismatch = $true
  SourceMailbox = (Get-Mailbox -SoftDeletedMailbox $source).DistinguishedName
  TargetMailbox = (Get-Mailbox $target).DistinguishedName }

New-MailboxRestoreRequest @param

################################################
#          new syntax ARCHIVE                  #
################################################
         $source = "SOURCE@DOMAIN.com"
         $target = "TARGET@DOMAIN.com"

          $param = @{ AllowLegacyDNMismatch = $true
   SourceMailbox = (Get-Mailbox -IncludeInactiveMailbox $source).DistinguishedName
   TargetMailbox = (Get-Mailbox $target).DistinguishedName
TargetRootFolder = "Recovered Archive"
 Sourceisarchive = "$true"
 Targetisarchive = "$true" }

New-MailboxRestoreRequest @param

################################################
# ARCHIVE to PRIMARY (not confirmed / not guarateed / best effort )
################################################
# compare-disable archive OR complete mailbox OR archiveGUID
################################################
#  SourceMailbox = ARCHIVE DistinguishedName   #
################################################
         $source = "SOURCE@DOMAIN.com"
         $target = "TARGET@DOMAIN.com"

          $param = @{ AllowLegacyDNMismatch = $true
   SourceMailbox = (Get-Mailbox -IncludeInactiveMailbox $source).DistinguishedName
   TargetMailbox = (Get-Mailbox $target).DistinguishedName
TargetRootFolder = "Recovered Archive"
 Sourceisarchive = "$true" }

New-MailboxRestoreRequest @param

################################################
#  SourceMailbox =  ARCHIVE - ArchiveGUID      #
################################################

         $source = "SOURCE@DOMAIN.com"
         $target = "TARGET@DOMAIN.com"

          $param = @{​ AllowLegacyDNMismatch = $true
   SourceMailbox = (Get-Mailbox -IncludeInactiveMailbox $source).ArchiveGUID
   TargetMailbox = (Get-Mailbox $target).DistinguishedName
TargetRootFolder = "Recovered Archive"
 Sourceisarchive = "$true" }​

New-MailboxRestoreRequest @param

################################################
#   SourceMailbox = $ArchiveGUID  manually     #
################################################

    $ArchiveGUID = "Archive GUID here"
         $target = "TARGET@DOMAIN.com"

          $param = @{​ AllowLegacyDNMismatch = $true
   SourceMailbox = $ArchiveGUID
   TargetMailbox = (Get-Mailbox $target).DistinguishedName
TargetRootFolder = "Recovered Archive"
 Sourceisarchive = "$true" }​

New-MailboxRestoreRequest @param

################################################
################################################

#status
get-MailboxRestoreRequest

#To check the progress of the restore:

Get-MailboxRestoreRequest ThereseRestore | Get-MailboxRestoreRequestStatistics | fl

#To troubleshoot:

Get-MailboxRestoreRequest ThereseRestore | Get-MailboxRestoreRequestStatistics -IncludeReport | fl

# to remove failed request
# get-MailboxRestoreRequest | remove-MailboxRestoreRequest
