<#
.SYNOPSIS
    Launches admin tools using elevated credentials.
.DESCRIPTION
    This script prompts for elevated credentials and then launches admin tools using the elevated credentials.
#>

# Prompt for admin credentials
$AdminCreds = Get-Credential -Message "Enter your admin credentials" -UserName "contoso.com\jsmith.admin"

if ($AdminCreds) {
# Open Microsoft Management Console with custom .msc file
Start-Process -FilePath "C:\Windows\System32\mmc.exe" -WorkingDirectory "\\contoso.com\home\jsmith" -ArgumentList "Admin MMC.msc" -WindowStyle Minimized -Credential $AdminCreds

# Open Remote Desktop Connection Manager
Start-Process "C:\Program Files (x86)\Microsoft\Remote Desktop Connection Manager\RDCMan.exe" -WindowStyle Minimized -Credential $AdminCreds

# Open Server Manager
Start-Process "C:\Windows\System32\ServerManager.exe" -WindowStyle Minimized -Credential $AdminCreds

# Open System Center Configuration Manager
Start-Process "C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\Microsoft.ConfigurationManagement.exe" -WindowStyle Minimized -Credential $AdminCreds

# Open Visual Studio Code
Start-Process -Path "C:\Program Files\Microsoft VS Code\bin\code.cmd" -WindowStyle Minimized -Credential $AdminCreds
}

# Exit the script
Exit