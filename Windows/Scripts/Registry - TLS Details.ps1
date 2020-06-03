$Servers= @" 
SRV01
SRV02
SRV02
"@ -split "`n" | ForEach-Object { $_.trim() }

$RegistryLocations = @"
HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols
HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client
HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server
HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client
HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server
"@ -split "`n" | ForEach-Object { $_.trim() }

$Output = $null

foreach ($RegistryLocation in $RegistryLocations) {
    Write-Verbose $RegistryLocation
    $Output += Invoke-Command -ComputerName $Servers -ScriptBlock { Get-ItemProperty -Path $Args[0] } -ArgumentList $RegistryLocation | Select-Object PSComputerName,@{name='RegistryLocation';expression={$RegistryLocation}},DisabledByDefault,Enabled | Sort-Object PSComputerName | Format-Table
}

Write-Output $Output