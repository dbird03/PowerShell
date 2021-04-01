<#
.SYNOPSIS
    Gets open files from a file share.
.DESCRIPTION
    Gets open files from a file share by creating a CIM session to the file server.
    Before running this script, use Get-Credential to create the $Credential variable containing credentials that have the necessary access to the file server.
.NOTES
    Author: David Bird
    Created: April 1, 2021
#>

#Requires -Module SmbShare

# Create a CIM session to the file server
$Params = @{
    ComputerName = 'FILESRV01'
    Credential = $Credential
}
$CimSession = New-CimSession @Params

# Get open files from the file
$OpenFiles = Get-SmbOpenFile -CimSession $CimSession

# Optionally use Where-Object to filter the files
$FilteredFiles = $OpenFiles | Where-Object {$_.Path -like '*Report.pdf'}

# Write the output
if ($FilteredFiles) {
    Write-Output $FilteredFiles
}
else {
    Write-Output $OpenFiles
}