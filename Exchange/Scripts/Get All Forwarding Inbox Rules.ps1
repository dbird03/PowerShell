# Get all mailboxes
$Mailboxes = Get-Mailbox -ResultSize Unlimited

# Get all inbox rules of all mailboxes
$InboxRules = $Mailboxes |  ForEach-Object { Get-InboxRule –Mailbox $_.alias }

# Select rules that have values for forwarding attributes
$ForwardingRules = $InboxRules | Where-Object { ( $_.forwardAsAttachmentTo -ne $Null ) -or ( $_.forwardTo -ne $Null ) -or ( $_.redirectTo -ne $Null )}
$ForwardingRules | Select-Object MailboxOwnerId,Name,Enabled,Priority,RuleIdentity,forwardingAsAttachmentTo,forwardTo,redirectTo | Sort-Object MailboxOwnerId | Export-Csv "C:\Temp\ForwardingRules.csv" -NoTypeInformation