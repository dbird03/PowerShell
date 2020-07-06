function Get-TeamOwner {
<#
.SYNOPSIS
    Gets Team Owner(s) of a Microsoft Teams team.
.DESCRIPTION
    Gets Team Owner(s) of a Microsoft Teams team.
.EXAMPLE
    PS C:\> Get-TeamOwner -GroupId 'abcdefgh-hijk-lmno-pqrs-tuvwxyz12345'
    Gets the Team Owner(s) of the Team with Group Id 'abcdefgh-hijk-lmno-pqrs-tuvwxyz12345'
.EXAMPLE
    PS C:\> $AllTeamsGroupIds = (Get-Team).GroupId
    PS C:\> Get-TeamOwner -GroupId $AllTeamsGroupIds
    Gets the GroupIds for all Teams and then gets the Team Owner(s) of each GroupId
.INPUTS
    System.String
.OUTPUTS
    PSObject
.NOTES
    Created: July 6, 2020
    Author: David Bird
#>
    [CmdletBinding()]
    param (
        [string[]]$GroupId
    )
    
    process {
        foreach ($Item in $GroupId) {
            $Team = Get-Team -GroupId $Item
            $TeamOwners = Get-TeamUser -GroupId $Team.GroupId -Role 'owner'

            foreach ($TeamOwner in $TeamOwners) {
                [PSCustomObject]@{
                    GroupId = $Team.GroupId
                    Displayname = $Team.DisplayName
                    Name = $TeamOwner.Name
                    User = $TeamOwner.User
                    UserId = $TeamOwner.UserId
                    Role = $TeamOwner.Role
                }
            }

        }
    }
}