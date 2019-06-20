<#
.SYNOPSIS
    This script gets members of multiple Active Directory groups.

.DESCRIPTION
    This script gets members of multiple Active Directory groups that use a similar naming convention
    and then exports a .csv file of the groups and their members.

    Note: This script will not include the group name in the .csv file if the group has no members.

.NOTES
    Version: 1.0
    Author: David Bird
    Creation Date: June 20th, 2019
#>

# Get the current date
$Date = Get-Date -UFormat "%Y-%m-%d %H %M %S %p"

# Set the export location and file name of the resulting .csv file
$ExportPath     = "C:\Temp"
$ExportFileName = "AD Groups and Members $Date.csv"

# Get a filtered list of the groups in Active Directory
$Groups = Get-ADGroup -Filter {Name -Like "SG FS Server *"} -Properties Name

# Creates an empty variable to store results
$Results = @()

# Get a list of the members of each group (recursively). Note: This will not specify nested groups.
Write-Host "Querying Active Directory groups..."
$Counter = 1
foreach ($Group in $Groups) {
Write-Progress -Activity "Querying Active Directory groups..." -Status "Querying $($Group.Name)" -PercentComplete (($Counter / $Groups.Length) * 100) 
$Results += Get-ADGroupMember -Identity $Group -Recursive | Get-ADUser | Select-Object @{Label="Active Directory Group Name";Expression={$Group.Name}}, Name, Enabled
$Counter += 1
}

# Export the results to a .csv file
$Results | Export-Csv -Path "$ExportPath\$ExportFileName" -NoTypeInformation

# Check if the file exists
if (-not (Test-Path -Path "$ExportPath\$ExportFileName"))
{
    throw "There was an error checking the export results"
} 
else
{
    Write-Host "Results exported successfully to `"$ExportPath\$ExportFileName`""
}
