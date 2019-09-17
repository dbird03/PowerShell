function Get-ExternalForwardingInboxRules {
<#
.SYNOPSIS
    Checks the inbox rules of mailboxes for rules that are forwarding to external domains.
.DESCRIPTION
    Checks the inbox rules of mailboxes for rules that are forwarding to external domains.
.PARAMETER MAILBOXES
    Mailbox objects from the Get-Mailbox cmdlet.
.EXAMPLE
    PS C:\> Get-ExternalForwardingInboxRules -Mailboxes (Get-Mailbox -ResultSize Unlimited) | Export-Csv -Path "C:\ExternalForwardingInboxRules.csv"
    Gets the external forwarding rules from all mailboxes and exports them to a csv file.
.LINK
    https://gcits.com/knowledge-base/find-inbox-rules-forward-mail-externally-office-365-powershell/
.NOTES
    This script was originally written by Elliot Munro and has been adapted in to a function that
    accepts mailboxes as input.
#>
    [CmdletBinding()]
    param (
        $Mailboxes     
    )
    
    begin {
    }
    
    process {
        # Get a list of accepted domains in Exchange which will be considered internal to your organization
        $AcceptedDomains = Get-AcceptedDomain
        foreach ($mailbox in $mailboxes) {
            
            # Create an empty variable $forwardingRules and get all inbox rules from $mailboxes where the forwardTo or forwardAsAttachmentTo or redirectTo attributes are not null.
            $forwardingRules = $null
            Write-Host "Checking rules for $($mailbox.displayName) - $($mailbox.primarySmtpAddress)" -foregroundColor Green
            $rules = Get-InboxRule -Mailbox $mailbox.primarySmtpAddress
             
            $forwardingRules = $rules | Where-Object {$_.forwardTo -or $_.forwardAsAttachmentTo -or $_.redirectTo}
         
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
                # If the $domain is not in the list of $AcceptedDomains, then add it to $externalRecipients
                $externalRecipients = @()
                foreach ($recipient in $recipients) {
                    $email = ($recipient -split "SMTP:")[1].Trim("]")
                    $domain = ($email -split "@")[1]
         
                    if ($AcceptedDomains.DomainName -notcontains $domain) {
                        $externalRecipients += $email
                    }    
                }
                
                # Anytime an object is added to $externalRecipients, write to the Host that a match was found.
                if ($externalRecipients) {
                    $extRecString = $externalRecipients -join ", "
                    Write-Host "$($rule.Name) forwards to $extRecString" -ForegroundColor Yellow

                    $Output = [PSCustomObject][Ordered]@{
                        PrimarySmtpAddress = $mailbox.PrimarySmtpAddress
                        DisplayName        = $mailbox.DisplayName
                        MailboxOwnerId     = $rule.MailboxOwnerId
                        RuleIdentity       = $rule.RuleIdentity
                        RuleId             = $rule.Identity
                        Enabled            = $rule.Enabled
                        RuleName           = $rule.Name
                        RuleDescription    = $rule.Description
                        ExternalRecipients = $extRecString
                    }

                    Write-Output $Output
                }#End if ($externalRecipients)
            }#End foreach ($rule in $forwardingRules)
        }#End foreach ($mailbox in $mailboxes)
    }#End process
    
    end {
    }
}
