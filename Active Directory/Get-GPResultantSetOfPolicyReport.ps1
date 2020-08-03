function Get-GPResultantSetOfPolicyReport {
<#
.SYNOPSIS
    Generates a Group Policy Resultant Set of Policy (RSoP) report.
.DESCRIPTION
    This function is a wrapper for the Get-GPResultantSetOfPolicy cmdlet which exports an HTML report with the date, time, and optional
    comment in the file name of the HTML report.

    The file name of the HTML report is:
    "GPResults $Date $User on $Computer.html" (if the Comment parameter is not used)

    "GPResults $Date $User on $Computer $Comment.html" (if the Comment parameter is not used)
.PARAMETER User
    The username of the user Resultant Set of Policy against.
.PARAMETER Computer
    The computer to run the Resultant Set of Policy against.
.PARAMETER Path
    The directory where you want to export the HTML report. If not specified, the function will use the prompt path where the function was run from.
.PARAMETER Comment
    A comment you want to specify in the file name of the HTML report. This can be helpful in troubleshooting such as "Baseline GPO report" or
    "After modifying Windows Desktop Default Policy GPO".
.EXAMPLE
    PS C:\> Get-GPResultantSetOfPolicyReport -User jsmith -Computer JSMITH-LAPTOP
    Generates a RSoP report for user jsmith logged on to the computer JSMITH-LAPTOP.

    PS C:\> Get-GPResultantSetOfPolicyReport -User admin -Computer RDSHOST01 -Comment "Before changing RDS GPO"
    Generates a RSoP report for user admin logged on to the computer RDSHOST01 and includes the comment in the file name.
.INPUTS
    This function does not take any object as input.
.OUTPUTS
    This function does not produce any object as output.
.NOTES
    Author: David Bird
    Created: May 20, 2020
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [String]$User,
        
        [Parameter(Mandatory = $true,Position=1)]
        [ValidateNotNullOrEmpty()]
        [String]$Computer,
        
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]$Path = (Get-Location).Path,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]$Comment
    )
    
    process {
        # Date Format example: 2020-05-20 14 00 00 PM
        $Date = Get-Date -UFormat "%Y-%m-%d %H %M %S %p"
        $ExportPath = "$Path\GPResults $Date $User on $Computer.html"

        if ($Comment) {
            $ExportPath = "$Path\GPResults $Date $User on $Computer $Comment.html"
        }
        <#
        The If block below is not processing correctly. If $ExportPath is greater than 260, it does not execute Write-Error or Exit.
        Instead, it continues and executes both Write-Verbose commands and then Get-GPResultantSetOfPolicy.
        #>
        if ($ExportPath.Length -ge 260) {
            Write-Error "Error: Full export path of report is greater than 260 characters. Please choose a different path or shorter comment if using the -Comment parameter."
            Exit
        }
        else {
        Write-Verbose "Generating Group Policy Resultant Set of Policy for $($User) on $($Computer)..."
        Write-Verbose "Report path: $($ExportPath)"
        Get-GPResultantSetOfPolicy -User $User -Computer $Computer -Path $ExportPath -ReportType 'Html'
        }
    }
}