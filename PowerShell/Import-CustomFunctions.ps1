function Import-CustomFunctions {
<#
.SYNOPSIS
    Imports custom functions in .ps1 files to the current session.
.DESCRIPTION
    This function is used to import miscellaneous custom functions in .ps1 files that are not in proper .psm1 module yet.

    IMPORTANT: You need to dot-source this function when using it within other functions or from the command line. See Examples for more details.

    Dot-source this function in your PowerShell profile, then create another function to call this function with the Path variable specific to your environment (Ex: If you store the PowerShell function folder on your company's network share.)

    # Profile.ps1
    . '\\contoso.com\home\Users\dbird\GitHub\PowerShell\PowerShell\Import-CustomFunctions.ps1'

    function icf {
    . Import-CustomFunctions -Path '\\contoso.com\home\Users\dbird\GitHub\PowerShell' -Verbose
    }
    # End Profile.ps1
.EXAMPLE
    PS C:\> . Import-CustomFunctions -Path 'C:\Scripts\PowerShell'
    Imports the custom functons in the 'C:\Scripts\PowerShell' path.
.NOTES
    Created: April 9, 2021
    Author: David bird
#>
    [CmdletBinding()]
    param (
        [string]$Path
    )

    begin {
        try {
            Write-Verbose -Message "Importing functions from $($Path)"
            Resolve-Path -Path $Path -ErrorAction Stop
        }
        catch {
            Write-Error $_
            Exit
        }
    }
    process {
        <#
        -Depth '1' is because functions are saved within the first subfolder in my PowerShell folder structure.
        Example:
        .\Active Directory\Get-Foo.ps1
        .\Active Directory\Scripts\DoSomething.ps1
        #>
        $Functions = Get-ChildItem -Path $Path -Filter '*.ps1' -Depth '1'
        foreach ($Function in $Functions) {
            . $Function.FullName
            Write-Verbose "Loading function: $($Function.FullName)"
        }
    }
}