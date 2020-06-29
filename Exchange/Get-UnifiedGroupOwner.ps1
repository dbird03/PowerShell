function Get-UnifiedGroupOwner {
<#
.SYNOPSIS
    Gets group owner(s) for Office 365 Groups
.DESCRIPTION
    Gets group owner(s) for Office 365 Groups
.EXAMPLE
    PS C:\> Get-UnifiedGroupOwner -Identity "Finance"
    Gets the group owner(s) of the Finance Office 365 Group
.INPUTS
    System.String
.OUTPUTS
    Deserialized.Microsoft.Exchange.Data.Directory.Management.ReducedRecipient
#>
    [CmdletBinding()]
    param (
        [string[]]$Identity
    )
    
    process {
        foreach ($Item in $Identity) {
            Get-UnifiedGroupLinks -Identity $Item -LinkType Owners
        }
    }
    
}