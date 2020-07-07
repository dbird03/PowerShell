function Get-UnifiedGroupWithTeam {
<#
.SYNOPSIS
    Gets Office 365 Group
.DESCRIPTION
    Takes the Name of an Office 365 Group and checks the ResourceProvisioningOptions property to see if it contains 'Teams' and outputs the
    entire Office 365 Group if true.
.EXAMPLE
    PS C:\> $AllUnifiedGroups = (Get-UnifiedGroup).Name 
    PS C:\> Get-UnifiedGroupWithTeam -Name $AllUnifiedGroups    
    Gets all Office 365 Groups and then passes them to Get-UnifiedGroupWithTeam to select only the groups with a Teams team provisioned.
.PARAMETER Name
    The Name property of the Office 365 Group
.INPUTS
    Name
.OUTPUTS
    Deserialized.Microsoft.Exchange.Data.Directory.Management.UnifiedGroupBase
.NOTES
    General notes
#>
    [CmdletBinding()]
    param (
        [string[]]$Name
    )

    
    process {
        foreach ($Item in $Name) {
            $UnifiedGroup = Get-UnifiedGroup -Identity $Item
            if ($UnifiedGroup.ResourceProvisioningOptions -contains 'Team') {
                $UnifiedGroup
            }
        }
    }

}