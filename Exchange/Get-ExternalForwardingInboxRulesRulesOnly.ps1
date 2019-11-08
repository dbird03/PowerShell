function Get-ExternalForwardingInboxRulesRulesOnly {
<#
.SYNOPSIS
    Checks the inbox rules of mailboxes for rules that are forwarding externally.
.DESCRIPTION
    Checks the inbox rules of mailboxes for rules that are forwarding externally.
.PARAMETER InboxRules
    Mailbox objects from the Get-Mailbox cmdlet.
.PARAMETER AcceptedDomains
    An array of domains that are considered to be internal domains and acceptable to forward emails to.
.EXAMPLE
    PS C:\> $Mailboxes = Get-Mailbox -ResultSize Unlimited    
    PS C:\> $Mailboxes | ForEach-Object { $InboxRules += Get-InboxRule –Mailbox $_.alias }
    PS C:\> $AcceptedDomains = Get-AcceptedDomain | Select-Object -ExpandProperty DomainName
    PS C:\> Get-ExternalForwardingInboxRulesRulesOnly -InboxRule $InboxRules -AcceptedDomain $AcceptedDomains
    Gets all mailboxes, gets all inbox rules from each mailbox, get accepted domains, then passes them to this function to find rules with external forwarding.
.EXAMPLE
    PS C:\> $Mailboxes = Get-Mailbox -ResultSize Unlimited    
    PS C:\> $Mailboxes | ForEach-Object { $InboxRules += Get-InboxRule –Mailbox $_.alias }
    PS C:\> Get-ExternalForwardingInboxRulesRulesOnly -InboxRules $InboxRule -AcceptedDomain 'contoso.com','gmail.com','yahoo.com'
    Gets all mailboxes, gets all inbox rules from each mailbox, specifies three accepted domains, then passes them to this function to find rules with external forwarding.
.EXAMPLE
    PS C:\> $Mailboxes = Get-Mailbox -ResultSize Unlimited    
    PS C:\> $Mailboxes | ForEach-Object { $InboxRules += Get-InboxRule –Mailbox $_.alias }
    PS C:\> $AcceptedDomains = Get-AcceptedDomain | Select-Object -ExpandProperty DomainName
    PS C:\> Get-ExternalForwardingInboxRulesRulesOnly -InboxRules $InboxRule -AcceptedDomain $AcceptedDomains,'gmail.com','yahoo.com'
    Gets all mailboxes, gets all inbox rules from each mailbox, gets accepted domains, then passes them to this function while adding two accepted domains to find rules with external forwarding.
.LINK
    https://gcits.com/knowledge-base/find-inbox-rules-forward-mail-externally-office-365-powershell/
#>
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        $InboxRule,

        [ValidateNotNullOrEmpty()]
        [string[]]$AcceptedDomain
    )
    
    begin {
        Write-Verbose "Accepted domains: $AcceptedDomain"
    }
    
    process {
        # Create an empty variable $forwardingRules and get all inbox rules where the forwardTo or forwardAsAttachmentTo or redirectTo attributes are not null.
        $forwardingRules = $null
        $forwardingRules = $InboxRule | Where-Object {$_.forwardTo -or $_.forwardAsAttachmentTo -or $_.redirectTo}

        # Create an empty variable $recipients
        # Enumerate through each $rule in $forwardingRules
        # Add any rules to $recipients where the forwardTo attribute has an SMTP string
        # Add any rules to $recipients where the forwardToAsAttachmentTo has an SMTP string
        # Add any rules to $recipients where the redirectTo has an SMTP string
        foreach ($rule in $forwardingRules) {
            $recipients = @()
            $recipients += $rule.ForwardTo | Where-Object {$_ -match "SMTP"}
            $recipients += $rule.forwardAsAttachmentTo | Where-Object {$_ -match "SMTP"}
            $recipients += $rule.redirectTo | Where-Object {$_ -match "SMTP"}
            
            # Create an empty variable $externalRecipients
            # Enumerate through each $recipient in $recipients, split the "SMTP:" string, split the domain from the email address
            # If the $domain is not in the list of $AcceptedDomain, then add it to $externalRecipients
            $externalRecipients = @()
            foreach ($recipient in $recipients) {
                $email = ($recipient -split "SMTP:")[1].Trim("]")
                $domain = ($email -split "@")[1]
        
                if ($AcceptedDomain -notcontains $domain) {
                    $externalRecipients += $email
                }    
            }
            
            # Anytime an object is added to $externalRecipients, write to the Host that a match was found.
            if ($externalRecipients) {
                $extRecString = $externalRecipients -join ", "
                Write-Host "$($rule.Name) forwards to $extRecString" -ForegroundColor Yellow

                $Output = [PSCustomObject][Ordered]@{
                    MailboxOwnerId     = $rule.MailboxOwnerId
                    RuleId             = $rule.Identity
                    RuleIdentity       = $rule.RuleIdentity
                    Enabled            = $rule.Enabled
                    RuleName           = $rule.Name
                    RuleDescription    = $rule.Description
                    ExternalRecipients = $extRecString
                }

                Write-Output $Output
            }#End if ($externalRecipients)
        }#End foreach ($rule in $forwardingRules)
    }#End process
    
    end {
    }
}
