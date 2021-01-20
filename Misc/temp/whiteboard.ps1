# credit goes to A. Zaki

#Install module 

Install-Module WhiteboardAdmin 

Import-Module whiteboardadmin

#ObjectID can be used as a UserID (Get-user "user" | fl ExternalDirectoryObjectId)

#List white board canvas for a given user.

Get-Whiteboard -UserId 4186359e-8754-4d8d-9df7-807c68ea4d8d 

#transfer whiteboards to a given user (after the transfer the old keeps access to the whiteboard until is revoked by an admin)

Invoke-TransferAllWhiteboards -OldOwnerId 4186359e-8754-4d8d-9df7-807c68ea4d8d -NewOwnerId 23b7fd9d-9ff7-4d1b-bdc4-efa77a743d30