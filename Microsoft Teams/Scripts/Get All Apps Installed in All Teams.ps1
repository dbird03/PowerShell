<#
.SYNOPSIS
    Gets a list of all apps installed in all teams.
.DESCRIPTION
    Gets a list of all apps installed in all teams.
.NOTES
    This script uses the Get-TeamsAppInstallation cmdlet which uses the Microsoft Graph Beta and is only available
    in the MicrosoftTeams version 1.1.3-preview module.
#>

#Requires -Modules @{ ModuleName="MicrosoftTeams"; RequiredVersion="1.1.3" }

# Get all teams
Write-Verbose "Getting all Teams" -Verbose
$AllTeams = Get-Team

# Get all apps in each team
foreach ($Team in $AllTeams) {
    $InstalledApps = Get-TeamsAppInstallation -TeamId $Team.GroupId
    
    foreach ($InstalledApp in $InstalledApps) {
        $Output = [PSCustomObject]@{
                    GroupId                 = $Team.GroupId
                    TeamDisplayName         = $Team.DisplayName
                    Id                      = $InstalledApp.Id
                    TeamsAppDefinitionId    = $InstalledApp.TeamsAppDefinitionId
                    TeamsAppId              = $InstalledApp.TeamsAppId
                    DisplayName             = $InstalledApp.DisplayName
                    Version                 = $InstalledApp.Version
        }

        $Output
    }
}