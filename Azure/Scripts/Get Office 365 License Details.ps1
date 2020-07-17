# Get all AccountSkus in the tenant (Ex: Contoso:ENTERPRISEPACK, Contoso:ENTERPRISEPREMIUM, etc.)
$AccountSkus = Get-MsolAccountSku | Where {$_.ConsumedUnits -ge 1 -and $_.AccountSkuId -eq "BMTC1:ENTERPRISEPREMIUM"}

# Enumerate through each AccountSku
foreach ($AccountSku in $AccountSkus) {
    # Get the users who are assigned the AccountSku
    $LicensedUsers = Get-MsolUser -All | Where-Object {$_.IsLicensed -eq "True" -and $_.Licenses.AccountSkuId -contains $AccountSku.AccountSkuId}

    # Enumerate through the users with the AccountSku and get the status of the services
    foreach ($LicensedUser in $LicensedUsers) {

        # Get the AccountSku of the user
        $MatchedAccountSku = $LicensedUser.Licenses | Where-Object {$_.AccountSkuId -eq $AccountSku.AccountSkuId}

        foreach ($Service in $MatchedAccountSku.ServiceStatus) {
            [PSCustomObject]@{
                UserPrincipalName = $LicensedUser.UserPrincipalName
                DisplayName = $LicensedUser.DisplayName
                ServiceName = $Service.ServicePlan.ServiceName
                ProvisioningStatus = $Service.ProvisioningStatus
            }
        }
    }

    #Export-Csv -Path "$($AccountSku.AccountName)_$($AccountSku.SkuPartNumber)_Users.csv" -InputObject $LicensedUsers -NoTypeInformation
}