function Get-UnifiedGroupWithTeam {
<#
.SYNOPSIS
    Gets Office 365 Group
.DESCRIPTION
    Takes the Identity of an Office 365 Group and checks the ResourceProvisioningOptions property to see if it contains 'Teams' and outputs the
    entire Office 365 Group if true.
.EXAMPLE
    PS C:\> $AllUnifiedGroups = (Get-UnifiedGroup).Identity 
    PS C:\> Get-UnifiedGroupWithTeam -Identity $AllUnifiedGroups    
    Gets the Identity property of all Office 365 Groups then uses Get-UnifiedGroupWithTeam to select only the groups with a Teams team provisioned.
.EXAMPLE
    PS C:\> (Get-UnifiedGroup).Identity | Get-UnifiedGroupWithTeam
    Gets the Identity property of all Office 365 Groups and then pipes them to Get-UnifiedGroupWithTeam to select only the groups with a Teams team provisioned.
.PARAMETER Identity
    The Identity property of the Office 365 Group
.INPUTS
    Identity
.OUTPUTS
    Deserialized.Microsoft.Exchange.Data.Directory.Management.UnifiedGroupBase
.NOTES
    General notes
#>
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True)]
        [string[]]$Identity
    )

    
    process {
        foreach ($Item in $Identity) {
            $UnifiedGroup = Get-UnifiedGroup -Identity $Item
            if ($UnifiedGroup.ResourceProvisioningOptions -contains 'Team') {
                $UnifiedGroup
            }
        }
    }

}