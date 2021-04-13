$Office365AdminCredential = Get-Credential -Message "Enter your Office 365 credentials with administrator access"
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $Office365AdminCredential -Authentication Basic –AllowRedirection
Import-PSSession $Session -AllowClobber

$UserMailbox = read-host "Enter the user's email address"
$SharedMailbox = read-host "Enter the shared mailbox's email address"


Add-MailboxPermission -Identity $SharedMailbox -User $UserMailbox -AccessRights FullAccess

Add-RecipientPermission -Identity $SharedMailbox -Trustee $UserMailbox -AccessRights SendAs -Confirm:$false

Read-Host -Prompt "Press Enter to exit"

Remove-PSSession $Session