function Find-TerminatedAdobeUsers {
<#
.SYNOPSIS
    Finds terminated users in the Adobe Admin Console.
.DESCRIPTION
    Compares a csv export of users from the Adobe Admin Console to the proxyAddresses attribute of all users in Active Directory to find
    terminated users in environments where single sign-on (SSO) has been configured. The Adobe Creative Cloud SSO configuration matches a user's
    email address in AD with their username in Creative Cloud to authenticate the user. This script uses the proxyAddress attribute to get all
    email addresses for a user including aliases since an alias may be used for their Creative Cloud username.
.PARAMETER AdobeUsersCsv
    The path to the csv export of users from the Adobe Admin Console. To generate this file: log in to the Adobe Admin Console
    (https://adminconsole.adobe.com/), select Users, click on the ellipsis, and choose "Export users lists to CSV". 
.EXAMPLE
    PS C:\> Find-TerminatedAdobeUsers -AdobeUsersCsv "C:\Temp\users.csv"
.EXAMPLE
    PS C:\> Find-TerminatedAdobeUsers -AdobeUsersCsv "C:\Temp\users.csv" | Export-Csv "C:\Temp\TerminatedAdobeUsers.csv" -NoTypeInformation
    Imports the csv of Adobe users and then exports the csv of terminated users.
.NOTES
    Created: September 23, 2019
    Author: David Bird
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]    
        $AdobeUsersCsv
    )
    
    begin {
        $AdobeUsers = Import-Csv -Path $AdobeUsersCsv

        # Get AD users' email addresses
        $ADUsers = Get-ADUser -Filter * -Properties proxyAddresses | Where-Object { ($_.proxyAddresses) }
        $ADEmailAddresses = ($ADUsers.proxyAddresses | Where-Object {$_ -match "SMTP"}) -split "," -replace "SMTP:"
    }
    
    process {
        foreach ($AdobeUser in $AdobeUsers) {
            If ($ADEmailAddresses -contains $AdobeUser.Email) {
                $AdobeUser | Add-Member -Type 'NoteProperty' -Name 'Terminated' -Value 'No' -Force
            }
            Else {
                Write-Output "$($AdobeUser.Email) has left the company"
                $AdobeUser | Add-Member -Type 'NoteProperty' -Name 'Terminated' -Value 'Yes' -Force
            }
        }
        $AdobeUsers | Where-Object {$_.Terminated -eq 'Yes'}
    }
    
    end {
        
    }
}
