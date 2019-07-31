<#
.Synopsis
  Collection of one-liner commands for disabling Forwarding within Outlook on the web (OWA).

.DESCRIPTION
  Collection of one-liner commands for disabling Forwarding within Outlook on the web (OWA).
  This does not cover disabling forwarding via inbox rules since this is accomplished by
  Transport Rules and Remote Domains.

.REFERENCE
  https://blogs.technet.microsoft.com/exovoice/2017/12/07/disable-automatic-forwarding-in-office-365-and-exchange-server-to-prevent-information-leakage/
  https://techcommunity.microsoft.com/t5/Exchange-Team-Blog/The-many-ways-to-block-automatic-email-forwarding-in-Exchange/ba-p/607579
#>

# Get mailboxes that have forwarding enabled. ForwardingAddress is set by IT personnel in Exchange admin center
# ForwardingSmtpAddress is set by the user in OWA
$Mailboxes = Get-Mailbox -ResultSize Unlimited -Filter {((ForwardingSmtpAddress -ne $null) -or (ForwardingAddress -ne $null))}
$Mailboxes | Select-Object Name,ForwardingAddress,ForwardingSmtpAddress

# Turn off forwarding on a user's mailbox (OWA and Exchange admin center)
Get-Mailbox -Identity user@contoso.com | Set-Mailbox -DeliverToMailboxAndForward $False -ForwardingAddress $null -ForwardingSmtpAddress $null

# Create a new management role called "MyBaseOptions-DisableForwarding", copying the the "MyBaseOptions" management role
New-ManagementRole -Name "MyBaseOptions-DisableForwarding" -Parent "MyBaseOptions"

# Remove the forwarding parameters from the "MyBaseOptions-DisableForwarding" management role
Set-ManagementRoleEntry -Identity "MyBaseOptions-DisableForwarding\Set-Mailbox" -Parameters "DeliverToMailboxAndForward","ForwardingAddress","ForwardingSmtpAddress" -RemoveParameter

# Verify the parameters are removed
(Get-ManagementRoleEntry -Identity "MyBaseOptions-DisableForwarding\Set-Mailbox").parameters

# Create the new role assignment policy called "Default Role Assignment Policy - Disable Forwarding" 
New-RoleAssignmentPolicy -Name "Default Role Assignment Policy - Disable Forwarding" -Description "This policy grants end users the permission to set their options in Outlook on the web and perform other self-administration tasks. This policy removes the Forwarding option from Outlook on the web." -Roles "MyContactInformation","MyProfileInformation","My ReadWriteMailbox Apps","My Custom Apps","MyTextMessaging","MyVoiceMail","MyMailSubscriptions","MyBaseOptions-DisableForwarding","My Marketplace Apps","MyRetentionPolicies"

# Set "Default Role Assignment Policy - Disable Forwarding" to be the default policy applied to all new mailboxes
Set-RoleAssignmentPolicy -Identity "Default Role Assignment Policy - Disable Forwarding" -IsDefault

# Get all existing mailboxes and change their role assignment policy to "Default Role Assignment Policy - Disable Forwarding"
Get-Mailbox -ResultSize Unlimited | Set-Mailbox -RoleAssignmentPolicy "Default Role Assignment Policy - Disable Forwarding"

# Get all mailbox plans and their role assignment policy
Get-MailboxPlan | Select-Object DisplayName,RoleAssignmentPolicy

# Set all mailbox plans to use the "Default Role Assignment Policy - Disable Forwarding" role assignment policy
Get-MailboxPlan | Set-Mailbox -RoleAssignmentPolicy "Default Role Assignment Policy - Disable Forwarding"
