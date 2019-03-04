<#
.DESCRIPTION
This script launches your administrator tools using your administrator credentials.
This is helpful for quickly launching your regularly used tools such as a custom MMC console, System Center Configuration Manager, etc.

.NOTES
    Version: 1.0
    Author: David Bird
    Creation Date: July 29, 2017

#>

# Prompt for administrator credentials
$AdministratorCredentials = Get-Credential -Message "Enter your administrator credentials" -UserName "contoso.com\david.bird"

# Open Microsoft Management Console with custom .msc file.
Start-Process -FilePath "C:\Windows\System32\mmc.exe" -ArgumentList "\\contoso.com\home\dbird\MMC.msc" -WindowStyle Minimized -Credential $AdministratorCredentials

# Open System Center Configuration Manager
Start-Process "C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\Microsoft.ConfigurationManagement.exe" -WindowStyle Minimized -Credential $AdministratorCredentials

# Open Remote Desktop Connection Manager
Start-Process "C:\Program Files (x86)\Microsoft\Remote Desktop Connection Manager\RDCMan.exe" -WindowStyle Minimized -Credential $AdministratorCredentials

# Open PowerShell ISE
Start-Process "C:\Windows\System32\WindowsPowerShell\v1.0\PowerShell_ISE.exe" -WindowStyle Minimized -Credential $AdministratorCredentials
