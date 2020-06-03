$Servers= @" 
SRV01
SRV02
SRV02
"@ -split "`n" | ForEach-Object { $_.trim() }

Invoke-Command -ComputerName $Servers {Get-WmiObject Win32_OperatingSystem | Select-Object -Property @{name='LastBootUpTime';expression={$_.ConvertToDateTime($_.LastBootUpTime)}}}