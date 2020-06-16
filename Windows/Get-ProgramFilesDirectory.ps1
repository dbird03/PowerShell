function Get-ProgramFilesDirectory {
<#
.SYNOPSIS
    Gets the list of Program Files and Program Files (x86) folders on a computer.
.DESCRIPTION
    Gets the list of Program Files and Program Files (x86) folders on a computer.
.PARAMETER COMPUTERNAME
    The name of the computer(s).
.EXAMPLE
    PS C:\> Get-ProgramFilesDirectory -ComputerName 'SRV01','SRV02'
    Gets a list of program files on computers SRV01 and SRV02.
.NOTES
    Created: October 1, 2019
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
        foreach ($Computer in $ComputerName) {
            $Results += Get-ChildItem "\\$Computer\C$\Program Files" | Select-Object FullName
            $Results += Get-ChildItem "\\$Computer\C$\Program Files (x86)" | Select-Object FullName
        }
    }
    
    end {
        Write-Output $Results
    }
}