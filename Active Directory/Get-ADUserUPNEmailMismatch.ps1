function Get-ADUserUPNEmailMismatch {
<#
.SYNOPSIS
    Returns a list of AD users whose userPrincipalName attribute does not match their emailAddress.
.DESCRIPTION
    Returns a list of AD users whose emailAddress attribute is not empty and whose userPrincipalName does not match their emailAddress.
.EXAMPLE
    PS C:\> Get-ADUserUPNEmailMismatch -SearchBase "OU=Users,DC=contoso,DC=com" | Select-Object Name,SamAccountName,UserPrincipalName,EmailAddress
    Searches the contoso.com\Users OU for AD users whose UserPrincipalName does not match their emailAddress attribute.
.OUTPUTS
    Selected.Microsoft.ActiveDirectory.Management.ADUser
#>
    [CmdletBinding()]
    param (
        [string]$SearchBase,
        [ValidateSet("Base","0","OneLevel","1","Subtree","2")]
        [string]$SearchScope
    )
    
    begin {
    }
    
    process {
        # Hash table for the base set of parameters to be used with Get-ADUser
        $params = @{
            'Filter' = {EmailAddress -ne "$Null"}
            'Properties' = "EmailAddress"
        }

        # Add additional parameters to the hash table if optional parameters were used
        switch ($PSBoundParameters.Keys) {
            'SearchBase' { $params.Add('SearchBase',"$SearchBase")}
            'SearchScope' { $params.Add('SearchScope',"$SearchScope")}
        }

        Get-ADUser @params | Where-Object { $_.UserPrincipalName -ne $_.EmailAddress }
    }
    
    end {
    }
}