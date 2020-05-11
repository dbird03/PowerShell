function Search-GPO {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$String
    )
    # Get all GPOs from the domain
    $GPOs = Get-GPO -All | Sort-Object DisplayName

    # Create an empty variable to store results
    $Result = @()

    # Create a counter variable for Write-Progress
    $Counter = 1
    
    # Enumerate through each GPO
    ForEach ($GPO in $GPOs) {
        $WriteProgressParams = @{
            Activity        = "Searching GPOs... ($($Counter) of $($GPOs.Length) GPOs)"
            Status          = "Searching GPO: $($GPO.DisplayName)"
            PercentComplete = (($Counter / $GPOs.Length) * 100)
        }
        Write-Progress @WriteProgressParams 
        
        # Get a report of the GPO in XML format
        $GetGPOReportParams = @{
            Guid       = $GPO.Id
            ReportType = "Xml"
        }
        $GPOReport = Get-GPOReport @GetGPOReportParams

        # Look through the GPO report for a match of $String and add the result to $Result
        if ($GPOReport -match $String) {
            $Output = [pscustomobject][ordered]@{
                Name = $GPO.DisplayName
                Match = "Yes"
            }
            $Result += $Output
        }
        else {
            $Output = [pscustomobject][ordered]@{
                Name = $GPO.DisplayName
                Match = "No"
            }
            $Result += $Output
        } # End if

        $Counter += 1
    }# End ForEach
    Write-Output $Result
}