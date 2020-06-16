function Get-LocalAdministrators {
<#
.SYNOPSIS
    Gets members of the local Administrators group.
.DESCRIPTION
    Gets members of the local Administrators group.
.EXAMPLE
    PS C:\> Get-LocalAdministrators -ComputerName "DC01", "DC02"
    Gets members of the local Administrators groups on servers DC01 and DC02
.NOTES
    Created: September 16, 2019
    Author: David Bird
#>
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName
    )
    
    begin {
    }
    
    process {
        $IVparams = @{
            ComputerName     = $ComputerName
            HideComputerName = $true
            ScriptBlock      = {
                                $members = net localgroup Administrators | 
                                Where-Object {$_ -AND $_ -notmatch "command completed successfully"} | 
                                Select-Object -Skip 4
                
                                [PSCustomObject][Ordered]@{
                                ComputerName = $env:COMPUTERNAME
                                Group        = "Administrators"
                                Members      = $members
                                }
                }
        }#End @IVParams
        
        Invoke-Command  @IVparams | 
        Select-Object * -ExcludeProperty RunspaceID  
    }#End process
    
    end {
    }
}