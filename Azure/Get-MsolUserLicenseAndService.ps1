function Get-MsolUserLicenseAndService {
<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>
    [CmdletBinding()]
    param (
        [string[]]$UserPrincipalName
    )
    
    begin {
        
    }
    
    process {
        foreach ($User in $UserPrincipalName) {
            $MsolUser = Get-MsolUser -UserPrincipalName $User
        }
    }
    
    end {
        
    }
}