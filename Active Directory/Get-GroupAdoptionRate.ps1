function Get-GroupAdoptionRate {
<#
.SYNOPSIS
    Displays a list of Active Directory groups that a supervisor's direct reports are a member of.
.DESCRIPTION
    Displays a list of Active Directory groups that a supervisor's direct reports are a member of.
.PARAMETER Supervisor
    The name of the supervisor. This uses the "name" attribute of the supervisor's Active Directory user account.
.PARAMETER GroupPercentage
    Specifies the the minimum percentage of direct reports that are members of a group.
.EXAMPLE
    PS C:\> Get-GroupAdoptionRate -Supervisor 'John Smith' -GroupPercentage 60
    Returns the groups that 60% of John Smith's direct reports are members of.
.NOTES
    Author: Unknown    
    This function was posted on either the TechNet Script Gallery or a tech blog.
#>
    [CmdletBinding()]    
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Supervisor,

        [Parameter(Mandatory=$true)]
        [int]$GroupPercentage
    )
 
    # List all employees of targeted supervisor
    $DirectReports = Get-ADUser -Identity (Get-ADUser -Filter {Name -eq $Supervisor}) -Properties directreports |
        Select-Object -ExpandProperty directreports |
        Get-ADUser -Properties name
 
    # List all groups of the DirectReports
    $DirectReportsGroups = $DirectReports | 
        ForEach-Object {
        (Get-ADUser -Identity $_.SamAccountName -Properties MemberOf).MemberOf | 
            Get-ADGroup | 
            Select-Object -ExpandProperty Name
        }
 
    # For each group determine % of users in subset that are member of a particular group
    $DirectReportsGroups |
        Group-Object | # Gets group count
        Sort-Object Name |
        Select-Object -Property Name, Count, @{
        Name       = 'Percentage'
        Expression = {(($_.Count / $DirectReports.Count) * 100).ToString("0.00")} # Creates percentage and two decimal places
    } | 
        Where-Object { $_.Percentage -ge $GroupPercentage }
}