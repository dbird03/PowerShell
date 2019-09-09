<#
.DESCRIPTION
This script creates Internet Explorer favorites out of printers' IP addresses on a print server.

.NOTES

    Version: 1.0
    Author: David Bird
    Creation Date: March 8, 2018

.SOURCES
http://powershellblogger.com/2016/01/create-shortcuts-lnk-or-url-files-with-powershell/
#>

# User-defined variables
$PrintServer = "PRINTSRV01"
$FavoritesPath = "\\contoso.com\users\username\Favorites\Links\Printers"

# Script variables
$Shell = New-Object -ComObject ("WScript.Shell")

# Get printers from print server
Write-Host "Getting printers from $PrintServer"...
$Printers = Get-Printer -ComputerName $PrintServer

ForEach ($Printer in $Printers) {
$PrinterName = $Printer.Name
$PortName = $Printer.PortName
$Favorite = $Shell.CreateShortcut("$FavoritesPath\$PrinterName.url")
$Favorite.TargetPath = "http://$PortName";
$Favorite.Save()
}
