<#
.SYNOPSIS
    Moves a set of files from one directory to another directory as part of scheduled task.

.DESCRIPTION
    This script moves a set of files from one directory to another directory as part of scheduled task for the following scenario:
    An application creates a set of files. The number of files can differ, but they all share the first same 7 characters
    and the final file that is produced ends with the extension ".fin". Once the .fin file is created, all files in the set of files
    need to be moved to another directory.

.NOTES
    Version: 1.0
    Author: David Bird
    Creation Date: July 1, 2019
#>

# $LandingPath is the folder that will be monitored
# $FinalPath is where the files will be moved to
$LandingPath = '\\server\share\OriginalPath'
$FinalPath   = '\\server\share\FinalPath'

# Check the $LandingPath for any .fin files and count how many there are
$FinFiles = Get-ChildItem -Path $LandingPath\*.fin
$FinCount = $FinFiles | Measure-Object 

# Copy the set of files if there are 1 or more .fin files
if ($FinCount.Length -ge '1') {
    foreach ($FinFile in $FinFiles) {
        # $FinPattern specifies the first 7 characters of the file name to copy
        $FinPattern = $FinFile.Name.Substring(0,7)
        Move-Item -Path $LandingPath\$FinPattern*.* -Destination $FinalPath
    }
}
