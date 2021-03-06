function Disable-MsolUserLicenseServicePlan {
    <#
    .SYNOPSIS
        Disables a specific service plan within a user's Office 365 License
    .DESCRIPTION
        This cmdlet disables a specific service plan within a user's Office 365 license without disabling or enabling the rest of the service plans.
    .EXAMPLE
        PS C:\> Disable-MsolUserLicenseServicePlan -UserPrincipalName 'jsmith@contoso.com' -AccountSkuId 'CONTOSO:ENTERPRISEPACK' -ServicePlanName 'TEAMS1' -Verbose
        Disables the 'Microsoft Teams' service plan license for user 'jsmith@contoso.com' in their Office 365 E3 license (which has the AccountSkuId 'CONTOSO:ENTERPRISEPACK').
    .EXAMPLE
        PS C:\> Disable-MsolUserLicenseServicePlan -UserPrincipalName 'jsmith@contoso.com' -AccountSkuId 'CONTOSO:ENTERPRISEPACK' -ServicePlanName 'STREAM_O365_E3' -Verbose
        Disables the 'Microsoft Stream for O365 E3 SKU' service plan license for user 'jsmith@contoso.com' in their Office 365 E3 license (which has the AccountSkuId 'CONTOSO:ENTERPRISEPACK').
    .EXAMPLE
        PS C:\> Disable-MsolUserLicenseServicePlan -UserPrincipalName 'jsmith@contoso.com' -AccountSkuId 'CONTOSO:ENTERPRISEPACK' -ServicePlanName 'SWAY' -Verbose
        Disables the 'Sway' service plan license for user 'jsmith@contoso.com' in their Office 365 E3 license (which has the AccountSkuId 'CONTOSO:ENTERPRISEPACK').
    .PARAMETER UserPrincipalName
        The UserPrincipalName of the user in Azure AD.
    .PARAMETER AccountSkuId
        The AccountSkuId of the user's license. Run the Get-MsolAccountSku for a list of account skus.
    .PARAMETER ServicePlanName
        The ServicePlanName of the service plan to disable.
    .INPUTS
        None
    .OUTPUTS
        None
    .LINK
        https://docs.microsoft.com/en-us/azure/active-directory/enterprise-users/licensing-service-plan-reference
    .LINK
        https://docs.microsoft.com/en-us/microsoft-365/enterprise/view-licenses-and-services-with-microsoft-365-powershell?view=o365-worldwide
    .LINK
        https://docs.microsoft.com/en-us/microsoft-365/enterprise/view-account-license-and-service-details-with-microsoft-365-powershell?view=o365-worldwide
    .NOTES
        Created: January 23, 2021
        Author: David Bird

        Requires you to be connected to the Msol Service before running this command by running Connect-MsolService.
    #>
    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='High')]
    param (
        [Parameter(Mandatory=$True)]
        [ValidateNotNull()]
        [string]$UserPrincipalName,
        [Parameter(Mandatory=$True)]
        [ValidateNotNull()]
        [string]$AccountSkuId,
        [Parameter(Mandatory=$True)]
        [ValidateNotNull()]
        [string]$ServicePlanName
    )
    
    process {
        # Get the Msol user
        Write-Verbose -Message "Getting MsolUser $($UserPrincipalName)"
        # Try getting the Msol user. If there are any errors, stop the script and throw the error message.
        try {
            $MsolUser = Get-MsolUser -UserPrincipalName $UserPrincipalName -ErrorAction Stop
        }
        catch {
            throw
        }
        
        # Get the AccountSku license details of the Msol user
        Write-Verbose -Message "Getting license $($AccountSkuId)"
        $License = $MsolUser.Licenses | Where-Object { $_.AccountSkuId -eq $AccountSkuId }
        # Verify a license was found for the AccountSkuId. Throw an terminating error if a license is not found.
        if (!$License) {
            throw "$($AccountSkuId) AccountSkuId not found for $($UserPrincipalName)"
        }
        # Verify the license of the AccountSkuId contains the ServicePlanName. Throw a terminating error if the ServicePlanName is not found.
        Write-Verbose -Message "Verifying $($AccountSkuId) contains $($ServicePlanName)"
        $LicenseServicePlans = $License.ServiceStatus.ServicePlan.ServiceName
        if ($LicenseServicePlans -notcontains $ServicePlanName) {
            throw "$($AccountSkuId) does not contain $($ServicePlanName)"
        }

        # Create an array of disabled ServicePlans in the license
        <#
         # The [System.Collections.Generic.List[string]] type is needed because:
         # 1. It supports the .Add() method below in the Else construct
         # 2. The -DisabledPlans parameter of New-MsolLicenseOptions uses the type: List<T>[String]
         #>
        Write-Verbose -Message "Getting DisabledPlans"
        [System.Collections.Generic.List[string]]$DisabledPlans = $License.ServiceStatus | Where-Object { $_.ProvisioningStatus -eq 'Disabled'} | Select-Object -ExpandProperty 'ServicePlan' | Sort-Object -Property 'ServiceName' | Select-Object -ExpandProperty 'ServiceName'
        Write-Verbose -Message "DisabledPlans:"
        foreach ($DisabledPlan in $DisabledPlans) {
            Write-Verbose -Message "    $($DisabledPlan)"
        }

        # Check if the ServicePlanName is in $DisabledPlans
        if ($DisabledPlans -contains $ServicePlanName) {
            Write-Verbose -Message "DisabledPlans contains $($ServicePlanName). No action needed."
        }
        else {
            Write-Verbose -Message "DisabledPlans does not contains $($ServicePlanName). Adding $($ServicePlanName) to Disabled Plans."
            $DisabledPlans.Add($ServicePlanName)
            Write-Verbose -Message "New DisabledPlans:"
            foreach ($DisabledPlan in $DisabledPlans) {
                Write-Verbose -Message "    $($DisabledPlan)"
            }
            if ($PSCmdlet.ShouldProcess("$UserPrincipalName", "Disable $($ServicePlanName) service plan in $($AccountSkuId) license")) {
                # Create the new license options
                $LicenseOptions = New-MsolLicenseOptions -AccountSkuId $AccountSkuId -DisabledPlans $DisabledPlans
                # Assign the new license options
                Set-MsolUserLicense -UserPrincipalName $UserPrincipalName -LicenseOptions $LicenseOptions
            }
        }
    }
}