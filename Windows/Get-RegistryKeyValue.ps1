function Get-RegistryKeyValue {
<#
.SYNOPSIS
    Gets Registry key values
.DESCRIPTION
    Gets Registry key values 
.EXAMPLE
    PS C:\> Get-RegistryKeyValue -Path "HKLM:SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" -Name EnableOplocks,MaxMpxCt -ComputerName 'FILSRV01' -Verbose
    Gets the EnableOplocks and MaxMpxCt key values on the FILSRV01 computer.
.NOTES
    Improvements needed:
    * Not requiring the $Name parameter, so the default behavior is all.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path,
        [Parameter(Mandatory=$true)]
        [string[]]$Name,
        [string[]]$ComputerName = $env:COMPUTERNAME
    )
    
    begin {
    }
    
    process {        
        foreach ($Computer in $ComputerName) {
            Write-Verbose "RegistryPath: $Path"
            Write-Verbose "Name(s): $Name"
            Write-Verbose "Computer(s): $Computer"
    
            $Output = Invoke-Command -ComputerName $Computer -ArgumentList $Path,$Name -ScriptBlock {      
                Get-ItemProperty -Path $Args[0] -Name $Args[1]
            } 
    
            Write-Output $Output
        }
    }
    
    end {
    }
}