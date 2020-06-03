<#
.DESCRIPTION
This script exports a csv file of AD users in a specified OU whose userPrincipalName attribute does not match their email address.

.NOTES
    Version: 1.0
    Author: David Bird
    Creation Date: July 16, 2018

#>

# User-defined variables
$Date = Get-Date -UFormat "%Y-%m-%d"
$SearchBase = "OU=Users,DC=contoso,DC=com"
$ExportCsvLocation = "\\contoso.com\users\username\PowerShell\Exports\AD-Mismatch-$Date.csv"

# Script
Get-ADUser -Filter * -SearchBase $SearchBase -Properties EmailAddress | Where-Object { $_.UserPrincipalName -ne $_.EmailAddress } | Select-Object Name,SamAccountName,UserPrincipalName,EmailAddress | Export-Csv $ExportCsvLocation -NoTypeInformation