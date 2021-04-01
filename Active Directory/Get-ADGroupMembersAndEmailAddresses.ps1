function Get-ADGroupMembersAndEmailAddresses {
<#
.SYNOPSIS
    Gets the members and email addresses of an AD group.
.DESCRIPTION
    Gets the members and email addresses of an AD group.
.EXAMPLE
    PS C:\> Get-ADGroupMembersAndEmailAddresses -Identity 'IT Department'
    Gets the members and email addresses of users who are a member of the IT Department AD group.
.EXAMPLE
    PS C:\> Get-ADGroupMembersAndEmailAddresses -Identity 'IT Department' -Recursive
    Gets the members and email addresses of users who are a member of the IT Department AD group or all groups within the IT Department AD group.
.PARAMETER Identity
    The identity of the AD group.
.PARAMETER Recursive
    This is a switch that will recurse through the AD group to get all nested AD users.
.NOTES
    Author: David Bird
    Created: April 1, 2021
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [string]$Identity,
        [switch]$Recursive
    )
    
    process {
        # Build hash table for Get-ADGroupMember
        $GetADGroupMember = @{
            Identity = $Identity
        }
        # If using the Recursive switch, add this to the hash table
        if ($PSBoundParameters.ContainsKey('Recursive')) {
            $GetADGroupMember += @{Recursive = $True}
        }
        # Get group members
        $GroupMembers = Get-ADGroupMember @GetADGroupMember

        # Filter user objects from the group members
        $ADUsers = $GroupMembers | Where-Object {$_.objectClass -eq 'user'}

        # Enumerate through each user object
        foreach ($ADUser in $ADUsers) {
            Get-ADUser -Identity $ADUser.SamAccountName -Properties proxyAddresses | Select-Object Name,SamAccountName,@{name='EmailAddress';expression={ ($_.proxyAddresses | Where-Object {$_ -clike "SMTP:*"}) -split "," -replace "SMTP:"  }}
        }
    }
}