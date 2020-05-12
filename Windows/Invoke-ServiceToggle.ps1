function Invoke-ServiceToggle {
<#
.SYNOPSIS
    Toggles the status of a service
.DESCRIPTION
    Checks the status of a service on a specified computer name and toggles the status between Running and Stopped
.PARAMETER ServiceName
    Specifies the name of the service
.PARAMETER ComputerName
    Specifies the name of the computer
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    System.String
.OUTPUTS
    System.ServiceProcess.ServiceController
#>
    [CmdletBinding()]
    param (
        [string]$ServiceName,
        [string]$ComputerName
    )
    
    begin {
    }
    
    process {
        Write-Verbose "Getting status of $ServiceName on $ComputerName"
        $Service = Get-Service $ServiceName -ComputerName $ComputerName
        Write-Verbose "$ServiceName status: $($Service.Status)"
        
        if ($Service.Status -eq "Running") {
            Write-Verbose "Stopping $($ServiceName)"
            $Service | Stop-Service -PassThru
        }
        else
        {
            Write-Verbose "Starting $ServiceName"
            $Service | Start-Service -PassThru
        }
    }#End process
    
    end {
    }
}