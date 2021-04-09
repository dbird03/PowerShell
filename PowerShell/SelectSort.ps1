function SelectSort {
<#
.SYNOPSIS
    Selects object properties and sorts objects by the same properties in a single cmdlet.
.EXAMPLE
    PS C:\> Get-Process | SelectSort -Property 'CPU','ProcessName'
    Selects the CPU and ProcessName properties and then sorts the objects by CPU.
.EXAMPLE
    PS C:\> Get-Process | SelectSort -Property 'CPU','ProcessName' -Descending
    Selects the CPU and ProcessName properties and then sorts the objects by CPU in descending order.
.EXAMPLE
    PS C:\> Get-Service | SelectSort -Property 'Status','ServiceName' -Ordered
    Selects the Status and ServiceName properties and then sorts the objects by Status first and ServiceName second.
.PARAMETER InputObject
    Specifies the PSObject to use as input for the cmdlet.
.PARAMETER Property
    Specifies the properties of the InputObject to select and sort by.
.PARAMETER Ordered
    This is a switch parameter that will use the order of the properties as the sort order in the output.
.PARAMETER Descending
    This is a switch parameter that will sort the output by descending instead of the default ascending.
.NOTES
    Created: April 9, 2021
    Author: David Bird

    This function was inspired by Steven Judd's 'ss' function.
#>

    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [PSObject]$InputObject,
        [string[]]$Property,
        [switch]$Ordered,
        [switch]$Descending
    )
    
    begin {
        $CustomPSObject = [System.Collections.Generic.List[Object]]::new()
    }
    
    process {
        foreach ($item in $InputObject) {
            $CustomPSObject.add($item)
        }
    }
    
    end {
        $SortObjectParameters = @{
            Property = $Property[0]
        }
        if ($PSBoundParameters.ContainsKey('Ordered')) {
            $SortObjectParameters = @{Property = $Property}
        }
        if ($PSBoundParameters.ContainsKey('Descending')) {
            $SortObjectParameters += @{Descending = $True}
        }
        $CustomPSObject | Select-Object -Property $Property | Sort-Object @SortObjectParameters
    }
}