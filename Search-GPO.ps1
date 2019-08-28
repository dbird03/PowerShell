function Search-GPO {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$String
    )
    # Get all GPOs from the domain
    $GPOs = Get-GPO -All | Sort-Object DisplayName

    # Creates an empty variable to store results
    $Result = @()

    $Counter = 1
    
    ForEach ($GPO in $GPOs) {
        Write-Progress -Activity "Searching GPOs... ($($Counter) of $($GPOs.Length) GPOs)" -Status "Searching $($GPO.DisplayName)" -PercentComplete (($Counter / $GPOs.Length) * 100) 
        $GPOReport = Get-GPOReport -Guid $GPO.Id -ReportType Xml

        if ($GPOReport -match $String) {
            Write-Output "** Match found in $($GPO.DisplayName) **"
            $Result += $GPO
        }
        else {
            Write-Output "No match found in $($GPO.DisplayName)"
        } # End if

        $Counter += 1
    } # End ForEach
} # End function
