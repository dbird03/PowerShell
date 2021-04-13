function Set-ExchangeOnlineMailbox100GBQuota {
<#
.SYNOPSIS
    Sets quota size for Exchange Online mailboxes.
.DESCRIPTION
    Sets quota size for Exchange Online mailboxes.
    Settings are: ProhibitSendQuota '99GB', ProhibitSendReceiveQuota '100GB', and IssueWarningQuota '98GB'
.EXAMPLE
    PS C:\> Set-ExchangeOnlineMailbox100GBQuota -Identity jsmith@contoso.com
    Sets the Exchange Online mailbox quota for the jsmith@contoso.com mailbox
.EXAMPLE
    PS C:\>$Mailboxes = Import-Csv "C:\Temp\AzureADUsers.csv"
    PS C:\>Set-ExchangeOnlineMailbox100GBQuota -Identity $Mailboxes.PrimarySmtpAddress -Verbose
#>
    [CmdletBinding()]
    param (
        [string[]]$Identity
    )
    
    begin {   
    }
    
    process {
        foreach ($Mailbox in $Identity) {
            Write-Verbose "Setting $Mailbox mailbox quotas..."
            Set-Mailbox $Mailbox -ProhibitSendQuota '99GB' -ProhibitSendReceiveQuota '100GB' -IssueWarningQuota '98GB'
        }
    }
    
    end {
    }
}