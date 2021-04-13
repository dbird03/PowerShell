<#
.SYNOPSIS
    Increase Exchange Online mailboxes to 100 GB

.DESCRIPTION
    This script gets Azure/Office 365 who have E3 or E5 licenses and should have 100 GB mailboxes
    and increases their limit to 100 GB if their mailbox is currently 50 GB.

.NOTES
    Author: David Bird
    Created: January 29, 2020

    This script uses Exchange Online PowerShell and the Azure AD PowerShell V2 module.
    You will need to connect to Exchange Online and Azure AD (Connect-AzureAD) prior to running
    this script.

    Reference: https://gcits.com/knowledge-base/increase-office-365-e3-mailboxes-100-gb-via-powershell/
#>

# Get all users who have an Office 365 Enterprise E3 or Microsoft 365 E5 license and should have 100 GB mailboxes
$AzureADUsers = Get-AzureADUser -All $True | Where-Object {$_.AssignedLicenses.SkuId -match "6fd2c87f-b296-42f0-b197-1e91e994b900" -or $_.AssignedLicenses.SkuId -match "06ebc4ee-1bb5-47dd-8120-11324bc54e06"}

# Get each user's mailbox and check their ProhitbiSendReceiveQuota
foreach ($AzureADUser in $AzureADUsers) {
    $Mailbox = Get-Mailbox -Identity $AzureADUser.UserPrincipalName
    if ($Mailbox.ProhibitSendReceiveQuota -notmatch "100 GB") {
        Write-Host "$($Mailbox.PrimarySmtpAddress) ProhibitSendReceiveQuota is not 100 GB"
    }
    if ($Mailbox.ProhibitSendQuota -notmatch "99 GB") {
        Write-Host "$($Mailbox.PrimarySmtpAddress) ProhibitSendQuota is not 99 GB"
    }
    if ($Mailbox.IssueWarningQuota -notmatch "98 GB") {
        Write-Host "$($Mailbox.PrimarySmtpAddress) IssueWarningQuota is not 98 GB"
    }
}