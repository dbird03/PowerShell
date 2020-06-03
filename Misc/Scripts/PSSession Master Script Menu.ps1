<#
.Synopsis
   This script creates an interactive menu to connect to different PowerShell sessions.

.DESCRIPTION
   This script creates an interactive menu to connect to different PowerShell sessions.

.EXAMPLE
   
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
$ServerFQDN = "EXCHANGE.contoso.com" # This is the FQDN of your on-prem Exchange server.
$orgName    = "contoso"              # This is the name of your Office 365 organization.

$menu=@"
1 Connect to Exchange On-Prem
2 Connect to Exchange Online
3 Connect to SharePoint Online
4 Connect to Azure Active Directory (MsolService)
Q Quit
 
Select a task by number or Q to quit
"@

Write-Host "My Menu" -ForegroundColor Cyan
$r = Read-Host $menu

Switch ($r) {

#--------[Exchange On-prem Session]--------
"1" {
   Write-Host "Connecting to Exchange On-Prem Session..." -ForegroundColor Green
   $ExchangeAdminCredential = Get-Credential -Message "Enter your Exchange admin credentials (domain.com\username)"
   $ExchangeOnPremSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$ServerFQDN/PowerShell/ -Authentication Kerberos -Credential $ExchangeAdminCredential
   Import-PSSession $ExchangeOnPremSession
}

#--------[Exchange Online Session]-------- 
"2" {
   Write-Host "Connecting to Exchange Online Session..." -ForegroundColor Green
   $Office365AdminCredential = Get-Credential -Message "Enter your Office 365 credentials with administrator access (username@domain.com)"
   $ExchangeOnlineSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Office365AdminCredential -Authentication Basic –AllowRedirection
   Import-PSSession $ExchangeOnlineSession -AllowClobber
}

#--------[SharePoint Online Session]-------- 
"3" {
   Write-Host "Connecting to SharePoint Online..." -ForegroundColor Green
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

#--------[Azure Active Directory]-------- 
"4" {
   Write-Host "Connecting to Azure Active Directory..." -ForegroundColor Green
   $Office365AdminCredential = Get-Credential -Message "Enter your Office 365 credentials with administrator access (username@domain.com)"
   Connect-MsolService -Credential $Office365AdminCredential
}
 
"Q" {
   Write-Host "Quitting" -ForegroundColor Green
}
 
default {
   Write-Host "The value you entered is not a valid choice." -ForegroundColor Yellow
 }
} #end switch
