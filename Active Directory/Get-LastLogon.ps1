function Get-LastLogon {
<#
.SYNOPSIS
    Gets the LastLogon property of a user
.DESCRIPTION
    Gets the LastLogon property of a user
.PARAMETER User
    The username of the user(s) to check.
.PARAMETER DomainController
    The server name of the domain controller(s) to check.
.EXAMPLE
    PS C:\> $DomainControllers = Get-ADDomainController -Filter * | Sort-Object Name | Select-Object -ExpandProperty Name
    PS C:\> Get-LastLogon -User jsmith -DomainController $DomainControllers -Verbose
    Gets all domain controllers and checks for user "jsmith"
.NOTES
    Created: March 4, 2020
    Author: David Bird
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [string[]]$User,
        [Parameter(Mandatory = $true,Position=1)]
        [ValidateNotNullOrEmpty()]
        [string[]]$DomainController
    )
    
    begin {
    }
    
    process {
        foreach ($DC in $DomainController) {
            Write-Verbose "Checking $DC ..."
            foreach ($UserObj in $User) {
                Write-Verbose "Checking $UserObj on $DC ..."
                $ADUser = Get-ADUser $UserObj -Properties LastLogon -Server $DC

                $Output = [PSCustomObject][Ordered]@{
                    Name                =   $ADUser.Name
                    UserPrincipalName   =   $ADUser.UserPrincipalName
                    Server              =   $DC
                    LastLogon           =   [datetime]::FromFileTime($ADUser.LastLogon)
                }

                Write-Output $Output
            }#End foreach ($UserObj in $User)
        }#End foreach ($DC in $DomainController)
    }
    
    end {   
    }
}