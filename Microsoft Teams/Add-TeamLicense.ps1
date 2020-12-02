function Add-TeamLicense {
    <#
    .SYNOPSIS
        Enables the Microsoft Teams license for a user
    .DESCRIPTION
        This function enables the Microsoft Teams license within a user's Office 365 license without enabling or disabling any 
        of the other apps and services in the user's license.
    .EXAMPLE
        PS C:\> Add-TeamLicense -UserPrincipalName 'jsmith@contoso.com' -AccountSkuId 'CONTOSO:ENTERPRISEPACK' -Verbose
        Enables the Microsoft Teams license for user jsmith@contoso.com in their Office 365 E3 license (CONTOSO:ENTERPRISEPACK AccountSkuId)
    .PARAMETER UserPrincipalName
        The UserPrincipalName of the user in Azure AD.
    .PARAMETER AccountSkuId
        The AccountSkuId of the user's license. Run the Get-MsolAccountSku for a list of account skus.
    .NOTES
        Requires you to be connected to the Msol Service before running this command by running Connect-MsolService.
    #>
        [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='High')]
        param (
            [Parameter(Mandatory=$True)]
            [ValidateNotNull()]
            [string]$UserPrincipalName,
            [Parameter(Mandatory=$True)]
            [ValidateNotNull()]
            [string]$AccountSkuId
        )
        
        process {
            # Get the Msol user
            Write-Verbose -Message "Getting MsolUser $($UserPrincipalName)"
            $MsolUser = Get-MsolUser -UserPrincipalName $UserPrincipalName
    
            # Get the specified license details of the Msol user
            Write-Verbose -Message "Getting license $($AccountSkuId)"
            $License = $MsolUser.Licenses | Where-Object { $_.AccountSkuId -eq $AccountSkuId }
    
            # Create an array of disabled ServicePlans in the license
            <#
             # The [System.Collections.Generic.List[string]] type is needed because:
             # 1. It supports the .Remove() method below in the Else construct
             # 2. The -DisabledPlans parameter of New-MsolLicenseOptions uses the type: List<T>[String]
             #>
            Write-Verbose -Message "Getting DisabledPlans"
            [System.Collections.Generic.List[string]]$DisabledPlans = $License.ServiceStatus | Where-Object { $_.ProvisioningStatus -eq 'Disabled'} | Select-Object -ExpandProperty 'ServicePlan' | Select-Object -ExpandProperty 'ServiceName'
            
            Write-Verbose -Message "DisabledPlans: $($DisabledPlans)"
            
            # Check for the Microsoft Teams ServicePlan in the $DisabledPlans array
            if ($DisabledPlans -notcontains 'TEAMS1') {
                Write-Verbose -Message "DisabledPlans does not contain TEAMS1. No action needed."
            }
            else {
                Write-Verbose -Message "DisabledPlans contains TEAMS1. Removing TEAMS1 from Disabled Plans."
                $DisabledPlans.Remove('TEAMS1')
                Write-Verbose -Message "New DisabledPlans: $($DisabledPlans)"
                if ($PSCmdlet.ShouldProcess("$UserPrincipalName", "Set new Msol license")) {
                    # Create the new license
                    $LicenseOptions = New-MsolLicenseOptions -AccountSkuId $AccountSkuId -DisabledPlans $DisabledPlans
                    # Assign the new license
                    Set-MsolUserLicense -UserPrincipalName $UserPrincipalName -LicenseOptions $LicenseOptions
                }
            }
        }
        
    }