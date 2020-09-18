function MouseWiggle {
<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Randomly positions the mouse every one second to keep remote desktop session alive.
.EXAMPLE
    PS C:\> MouseWiggle
    Begins randomly position the mouse.
.NOTES
    Author: Lee Holmes (@Lee_Holmes)
.LINK
    https://twitter.com/lee_holmes/status/1307027949116293120
#>
    [CmdletBinding()]
    param (
    )
    Add-Type -Assembly System.Windows.Forms
    while($true) {
        Start-Sleep -Seconds 1
        [Windows.Forms.Cursor]::Position = New-Object Drawing.Point (random 1000),(random 1000)
    }
}