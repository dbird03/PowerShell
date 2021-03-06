<#
.SYNOPSIS
   This script creates functions to connect to the different PSSessions commonly used by Microsoft system administrators.

.DESCRIPTION
   This script creates functions to connect to the different PSSessions commonly used by Microsoft system administrators.

.EXAMPLE
   Run this script, then use one of the functions to connect to a PSSession.
   PS C:\Users\dbird> Connect-ExchangeOnPremSession
   
.NOTES
   Version: 1.0
   Author: David Bird
   Creation Date: March 4, 2019

.SOURCES
https://docs.microsoft.com/en-us/powershell/exchange/exchange-server/connect-to-exchange-servers-using-remote-powershell?view=exchange-ps
https://docs.microsoft.com/en-us/powershell/exchange/exchange-online/connect-to-exchange-online-powershell/connect-to-exchange-online-powershell?view=exchange-ps
https://docs.microsoft.com/en-us/powershell/sharepoint/sharepoint-online/connect-sharepoint-online?view=sharepoint-ps
#>

# User-defined variables
$ServerFQDN = "EXCH2016.contoso.com" # This is the FQDN of your on-prem Exchange server.
$orgName    = "contoso"              # This is the name of your Office 365 organization.

#--------[Exchange On-prem Session]--------
function Connect-ExchangeOnPremSession
{
$ExchangeAdminCredential = Get-Credential -Message "Enter your Exchange admin credentials (domain.com\username)"
$ExchangeOnPremSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$ServerFQDN/PowerShell/ -Authentication Kerberos -Credential $ExchangeAdminCredential
Import-PSSession $ExchangeOnPremSession

# Remember to run the below command when finished!
# Remove-PSSession $ExchangeOnPremSession
}

#--------[Exchange Online Session]--------
function Connect-ExchangeOnlineSession
{
$Office365AdminCredential = Get-Credential -Message "Enter your Office 365 credentials with administrator access (username@domain.com)"
$ExchangeOnlineSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Office365AdminCredential -Authentication Basic –AllowRedirection
Import-PSSession $ExchangeOnlineSession -AllowClobber

# Remember to run the below command when finished!
# Remove-PSSession $ExchangeOnlineSession
}

#--------[SharePoint Online Session]--------
function Connect-SharePointOnlineSession
{
if (Get-Module -ListAvailable -Name Microsoft.Online.SharePoint.PowerShell)
{
$Office365AdminCredential = Get-Credential -Message "Enter your Office 365 credentials with administrator access (username@domain.com)"
Connect-SPOService -Url https://$orgName-admin.sharepoint.com -Credential $Office365AdminCredential
}
else
{
Write-Host "Required module 'Microsoft.Online.SharePoint.PowerShell' is NOT installed.`
See the following URL for how to install this module: https://docs.microsoft.com/en-us/powershell/sharepoint/sharepoint-online/connect-sharepoint-online?view=sharepoint-ps"
}
}
