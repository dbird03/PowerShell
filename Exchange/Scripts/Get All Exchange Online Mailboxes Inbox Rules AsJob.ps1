# Connect to Exchange Online
$Office365AdminCredential = Get-Credential -Message "Enter your Office 365 credentials with administrator access (username@domain.com)"
$ExchangeOnlineSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Office365AdminCredential -Authentication Basic -AllowRedirection
Import-PSSession $ExchangeOnlineSession -AllowClobber

# Get all mailboxes as a background job
Invoke-Command -Session $ExchangeOnlineSession -ScriptBlock {Get-InboxRule -Mailbox (Get-Mailbox -ResultSize Unlimited)} -AsJob -JobName "GetAllMailboxesInboxRules"