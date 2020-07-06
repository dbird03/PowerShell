# Get all Teams
Write-Verbose "Getting all Teams" -Verbose
$AllTeams = Get-Team

# Get all Teams users from all Teams and output unique UserIds (remove duplicates)
$TeamsUsers = $AllTeams | ForEach-Object {
    Write-Verbose "Checking Teams users in $($_.GroupId)" -Verbose
    Get-TeamUser -GroupId $_.GroupId
} | Sort-Object UserId -Unique

# Output Teams users
$TeamsUsers