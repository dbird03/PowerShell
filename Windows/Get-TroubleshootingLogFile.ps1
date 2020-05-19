function Get-TroubleshootingLogFile {
<#
.SYNOPSIS
    Returns log files modified within a time range.
.DESCRIPTION
    Returns log files modified within a time range.
.EXAMPLE
    PS C:\> Get-TroubleshootingLogFile -ComputerName 'localhost' -StartTime '05-19-2020 08:00' -EndTime '05-19-2020 14:00'
    Returns log files modified on the localhost between 05/09/2020 8:00 AM and 2:00 PM.
.NOTES
    This function is created by Adam Bertram as part of his PluralSight course "PowerShell Toolmaking Fundamentals".
#>
    [CmdletBinding()]
    param (
        [string]$ComputerName,
        [datetime]$StartTime,
        [datetime]$EndTime,
        [string]$LogFileExtension = 'log'
    )

    process {
        # Get the locations of shares to check for logs
        if ($ComputerName -eq 'localhost') {
            $Locations = (Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType = '3'").DeviceID
        }
        else {
            $Shares = Get-CimInstance -ComputerName $ComputerName -ClassName Win32_Share | Where-Object { $_.Path -match '^\w{1}:\\$' }
            [System.Collections.ArrayList]$Locations = @()
            foreach ($Share in $Shares) {
                $Share = "\\$ComputerName\$($Share.Name)"
                if (!(Test-Path $Share)) {
                    Write-Warning "Unable to access the '$Share' share on $ComputerName'"
                }
                else {
                    $Locations.Add($Share) | Out-Null
                }
            }
        }

        # Get the log files from the shares
        $GciParams = @{
            Path        = $Locations
            Filter      = "*.$LogFileExtension"
            Recurse     = $True
            Force       = $True
            ErrorAction = 'SilentlyContinue'
            File        = $True
        }

        $WhereFilter = {($_.LastWriteTime -ge $StartTime) -and ($_.LastWriteTime -le $EndTime) -and ($_.Length -ne 0)}

        Get-ChildItem @GciParams | Where-Object $WhereFilter
    }#End process
}