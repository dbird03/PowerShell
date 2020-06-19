$VerbosePreference ="Continue"

# Get all DFSR connections first
$DfsrConnections = Get-DfsrConnection -GroupName "contoso.com\home\users"

# Check the backlog for each connection
foreach ($DfsrConnection in $DfsrConnections) {
    Write-Verbose "Checking DFSR Connection for Replication Group: $($DfsrConnection.GroupName) ($($DfsrConnection.SourceComputerName) => $($DfsrConnection.DestinationComputerName))" 
    $VerboseMessage = ($Null = $DfsrConnection | Get-DfsrBacklog -Verbose) 4>&1
    $VerboseMessage
}