# Function to convert UTC time to local time
function Convert-UTCtoLocal {
<#
.NOTES
    The following links were used as reference.
    https://devblogs.microsoft.com/scripting/powertip-convert-from-utc-to-my-local-time-zone/
    https://blog.tyang.org/2012/01/11/powershell-script-convert-to-local-time-from-utc/
#>
    param(
        [parameter(Mandatory=$true)]
        [String] $UTCTime
)

$strCurrentTimeZone = (Get-WmiObject win32_timezone).StandardName
$TZ = [System.TimeZoneInfo]::FindSystemTimeZoneById($strCurrentTimeZone)
$LocalTime = [System.TimeZoneInfo]::ConvertTimeFromUtc($UTCTime, $TZ)
Write-Output $LocalTime
}

Import-Module ADSync
Convert-UTCtoLocal -UTCTime (Get-ADSyncScheduler | Select-Object -ExpandProperty NextSyncCycleStartTimeInUTC)
