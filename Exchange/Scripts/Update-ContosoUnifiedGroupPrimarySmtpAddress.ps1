function Update-ContosoUnifiedGroupPrimarySmtpAddress {
<#
.SYNOPSIS
    Updates the PrimarySmtpAddress of a Microsoft/Office 365 Group (UnifiedGroup).
.DESCRIPTION
    Updates the PrimarySmtpAddress of a Microsoft/Office 365 Group (UnifiedGroup) to the Alias + @contoso.com domain.
.EXAMPLE
    PS C:\> Update-ContosoUnifiedGroupPrimarySmtpAddress -Identity 'Microsoft 365 Demo Group'
    Updates the PrimarySmtpAddress of the 'Microsoft 365 Demo Group' Microsoft 365 Group so the email address is Microsoft365DemoGroup@contoso.com.
.INPUTS
    Identity [System.String]
.NOTES
    Author: David Bird
    Created: August 21, 2020

    This script was written for a specific organization to update the PrimarySmtpAddress of their domain.
    This script needs additional work, but it is the first script I wrote that has support for WhatIf and Confirm,
    so I wanted to upload it to my GitHub repo as an example for later reference.

    Additional work needed:
    * Remove hardcoded contoso.com domain and add Domain parameter (also update the function name)
#>
    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='High')]
    param (
        [string[]]$Identity
    )

    process {
        foreach ($item in $Identity) {

            # Get the unified group
            Write-Output "Getting unified group '$item'"
            $UnifiedGroup = Get-UnifiedGroup -Identity $item

            # Display current information about the unified group
            Write-Output "Current Alias for $($item): $($UnifiedGroup.Alias)"
            Write-Output "Current PrimarySmtpAddress for $($item): $($UnifiedGroup.PrimarySmtpAddress)"

            # Build the hashtable of values to splat with Set-UnifiedGroup
            $UnifiedGroupParams = @{
                Identity = "$($UnifiedGroup)"
                PrimarySmtpAddress = "$($UnifiedGroup.Alias)@contoso.com"
            }

            # Display what the unified group's PrimarySmtpAddress will be set to
            Write-Output "PrimarySmtpAddress for $($item) will be set to $($UnifiedGroupParams.PrimarySmtpAddress)"

            if ($PSCmdlet.ShouldProcess($item)) {
                Set-UnifiedGroup @UnifiedGroupParams

                # Display the unified group's new PrimarySmtpAddress
                $UnifiedGroupAfter = Get-UnifiedGroup -Identity $item
                Write-Output "New PrimarySmtpAddress for $($item): $($UnifiedGroupAfter.PrimarySmtpAddress)"
            }
            else {
                Write-Output "No changes were made to '$($item)'."
            }

        }
    }
}