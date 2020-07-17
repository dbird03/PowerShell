<#
.SYNOPSIS
    Creates a csv for each Office 365 license containing the list of users assigned the license and the provisioning status of each service within the license.
.DESCRIPTION
    Creates a csv for each Office 365 license containing the list of users assigned the license and the provisioning status of each service within the license.
.EXAMPLE
    PS C:\> .\Get Office 365 License Details.ps1
    Runs the script and outputs the csv files in the same directory as the script.
.INPUTS
    AccountSku
.OUTPUTS
    PSCustomObject
.NOTES
    Created: July 17, 2020
    Author: David Bird
    References:
    https://mymicrosoftexchange.wordpress.com/2015/03/23/office-365-script-to-get-detailed-report-of-assigned-licenses/
    https://gallery.technet.microsoft.com/scriptcenter/Export-a-Licence-b200ca2a
#>

$VerbosePreference = "Continue"

# Get all AccountSkus (Ex: Contoso:ENTERPRISEPACK, Contoso:ENTERPRISEPREMIUM, etc.) in the tenant that have at least one licensed assigned to a user
Write-Verbose "Getting all AccountSkus..."
$AccountSkus = Get-MsolAccountSku | Where {$_.ConsumedUnits -ge 1}

# Enumerate through each AccountSku
foreach ($AccountSku in $AccountSkus) {
    Write-Verbose "Getting users in $($AccountSku.AccountSkuId)"
    # Get the users who are assigned the AccountSku
    $LicensedUsers = Get-MsolUser -All | Where-Object {$_.IsLicensed -eq "True" -and $_.Licenses.AccountSkuId -contains $AccountSku.AccountSkuId}

    # Enumerate through the users with the AccountSku
    foreach ($LicensedUser in $LicensedUsers) {

        # Get the AccountSku of the user
        $MatchedAccountSku = $LicensedUser.Licenses | Where-Object {$_.AccountSkuId -eq $AccountSku.AccountSkuId}

        # Create the basic output properties for the user
        $Output = [PSCustomObject]@{
            UserPrincipalName = $LicensedUser.UserPrincipalName
            DisplayName = $LicensedUser.DisplayName
        }

        # Add columns for each ServiceName in the ServicePlan to include the ProvisioningStatus (Success, Disabled, PendingActivation, PendingProvisioning)
        foreach ($Service in $MatchedAccountSku.ServiceStatus) {
            $Output | Add-Member -NotePropertyName $Service.ServicePlan.ServiceName -NotePropertyValue $Service.ProvisioningStatus
        }

        # Export the output to a csv file
        Export-Csv -Path "$($AccountSku.AccountName)_$($AccountSku.SkuPartNumber)_Users.csv" -InputObject $Output -Append -NoTypeInformation
    }
}