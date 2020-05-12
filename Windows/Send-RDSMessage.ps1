function Send-RDSMessage {
<#
.SYNOPSIS
    Sends a message to all users on a Remote Desktop Session Host.
.DESCRIPTION
    Sends a message to all users on a Remote Desktop Session Host.
.PARAMETER COMPUTERNAME
    The name of the computers to send the message to.
.PARAMETER MESSAGE
    The message to send to the computers.
.EXAMPLE
    PS C:\> Send-RDSMessage -ComputerName 'RDS01','RDS02' -Message 'Please save your work and log off.'
    Sends the message to all users on RDS01 and RDS02.
.NOTES
    Created: September 30, 2019
    Author: David Bird
#>
    [CmdletBinding()]
    param (
        [string[]]$ComputerName,
        [string]$Message
    )
    
    begin {
    }
    
    process {
        foreach ($Computer in $ComputerName) {
            MSG * /server:$Computer /v "$Message"
        }
    }
    
    end {
    }
}