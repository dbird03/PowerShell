<#
.DESCRIPTION
    This script will connect to Exchange Online and then start a background job to get all mailboxes.

    After running this script, you can use Receive-Job cmdlet to return the results. Use the -OutVariable switch to output to a variable.

.EXAMPLE
    PS C:\> ".\Get All Exchange Online Mailboxes AsJob.ps1"
    PS C:\> Receive-Job -Name "GetAllMailboxes" -Keep -OutVariable AllMailboxes
    Runs the script and saves the results to the $AllMailboxes variable. (Note: The $ character is not used with -OutVariable switch)
#>

# Connect to Exchange Online
$Office365AdminCredential = Get-Credential -Message "Enter your Office 365 credentials with administrator access (username@domain.com)"
$ExchangeOnlineSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Office365AdminCredential -Authentication Basic -AllowRedirection
Import-PSSession $ExchangeOnlineSession -AllowClobber

# Get all mailboxes as a background job
Invoke-Command -Session $ExchangeOnlineSession -ScriptBlock {Get-Mailbox -ResultSize Unlimited} -AsJob -JobName "GetAllMailboxes"