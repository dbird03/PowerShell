function Get-WinEventAggregate {
<#
.SYNOPSIS
    Retrieves Windows Event Log log files
.DESCRIPTION
    Retrieves Windows Event Log log files
.EXAMPLE
    PS C:\> Get-WinEventAggregate -ComputerName "localhost" -StartTime "05-14-2020 15:00" -EndTime "05-14-2020 15:30"
    Retrieves log files from the local computer between May 14, 2020 at 3:00 PM and 3:30 PM.
.NOTES
    This function is created by Adam Bertram as part of his PluralSight course "PowerShell Toolmaking Fundamentals".
#>
    [CmdletBinding()]
    param (
        [string]$ComputerName = 'localhost',
        [datetime]$StartTime,
        [datetime]$EndTime
    )
    
    process {
        $Logs = (Get-WinEvent -ListLog '*' -ComputerName $ComputerName | Where-Object { $_.RecordCount } | Select-Object -ExpandProperty 'LogName')
        $FilterHashtable = @{
            'LogName'   = $Logs
            'StartTime' = $StartTime
            'EndTime'   = $EndTime
        }        

        Get-WinEvent -ComputerName $ComputerName -FilterHashtable $FilterHashtable
    }
}