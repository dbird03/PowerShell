function Copy-PnPSharepointSitePage {
<#
.SYNOPSIS
    Copies a SharePoint site page to another SharePoint site.

.DESCRIPTION
    Copies a SharePoint site page to another SharePoint site.

    Note: This does not copy some content linked on the page, such as embedded images.

.EXAMPLE
    PS C:\> $Credential = Get-Credential
    PS C:\> Copy-PnPSharepointSitePage -SourceSiteUrl = 'https://contoso.sharepoint.com/sites/HumanResources' -DestinationSiteUrl = 'https://contoso.sharepoint.com/sites/Intranet' -PageName = 'Company-Policies.aspx' -Credential = $Credential

    This example copies the Company-Policies.aspx page from the 'https://contoso.sharepoint.com/sites/HumanResources' site to the 'https://contoso.sharepoint.com/sites/Intranet' site.

.PARAMETER SourceSiteUrl
    The URL of the source SharePoint site.

.PARAMETER DestinationSiteUrl
    The URL of the destination SharePoint site.

.PARAMETER PageName
    The name of the page to copy.

.NOTES
    Author: David Bird
    Created: October 8, 2020

    This function is an adaptation from the following blog post:
    https://www.c-sharpcorner.com/blogs/copy-sites-page-from-one-site-to-another-using-pnp-powershell2
#>

#Requires -Modules SharePointPnPPowerShellOnline

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $SourceSiteUrl,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $DestinationSiteUrl,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $PageName,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $Credential
    )
    
    process {
        # Connect to the source site and copy the page
        Connect-PnPOnline -Url $SourceSiteUrl -Credentials $Credential
        $tempFile = [System.IO.Path]::GetTempFileName();
        Export-PnPClientSidePage -Identity $PageName -Out $tempFile

        # Connect to the destination site and create the page
        Connect-PnPOnline -Url $DestinationSiteUrl -Credentials $Credential
        Apply-PnPProvisioningTemplate -Path $tempFile
    }
}