$Servers= @" 
RDS01
RDS02
RDS03
"@ -split "`n" | ForEach-Object { $_.trim() }

$RegistryLocations = @"
HKLM:SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp
HKLM:SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services
HKLM:SOFTWARE\Wow6432Node\Policies\Microsoft\Windows NT\Terminal Services
HKLM:SYSTEM\CurrentControlSet\Control\Terminal Server\DefaultUserConfiguration
HKCU:SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services
"@ -split "`n" | ForEach-Object { $_.trim() }


foreach ($RegistryLocation in $RegistryLocations) {
    Write-Output $RegistryLocation
    Invoke-Command -ComputerName $Servers -ScriptBlock {Get-ItemProperty -Path $Args[0] | Select-Object fResetBroken,MaxConnectionTime,MaxDisconnectionTime,MaxIdleTime,RemoteAppLogoffTimeLimit,fInheritMaxDisconnectionTime,fInheritMaxIdleTime} -ArgumentList $RegistryLocation | Sort-Object PSComputerName | Format-Table
}