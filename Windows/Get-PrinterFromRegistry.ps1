function Get-PrinterFromRegistry {
    [CmdletBinding()]
    param (
        [string[]]$ComputerName = $env:computername
    )
    
    begin {
$RegistryLocations = @"
HKLM:SYSTEM\CurrentControlSet\Control\Print\Printers
"@ -split "`n" | ForEach-Object { $_.trim() }
    }
    
    process {
        foreach ($RegistryLocation in $RegistryLocations) {
            Write-Output $RegistryLocation
            Invoke-Command -ComputerName $ComputerName -ScriptBlock {Get-ChildItem -Path $Args[0] | Select-Object PSComputerName,PSChildName} -ArgumentList $RegistryLocation | Sort-Object PSComputerName,PSChildName
        }
    }
    
    end {
    }
}