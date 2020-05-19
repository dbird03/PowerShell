function Get-TroubleshootingLogFile {
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