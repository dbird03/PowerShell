#requires -runasadministrator

#Paolo Frigo, https://www.scriptinglibrary.com
# 
##RdpSessionTable will contain all your results
function New-RdpSessionTable() {
    $RDPSessionTable = New-Object System.Data.DataTable("RDPSessions")
    "COMPUTERNAME", "USERNAME", "ID", "STATE" | ForEach-Object {
        $Col = New-Object System.Data.DataColumn $_ 
        $RDPSessionTable.Columns.Add($Col)
    }
    return , $RDPSessionTable
}
##
function Get-RemoteRdpSession {
    <#
    .SYNOPSIS
        This function is a simple wrapper of query session / qwinsta and returs a DataTable Objects

    .DESCRIPTION      
        This function is a simple wrapper of query session / qwinsta and returs a DataTable Objects

    .PARAMETER ComputerName
        ComputerName parameter is required to specify a list of computers to query

    .PARAMETER State
        State parameter is optional and can be set to "ACTIVE" or "DISC". If not 
        used both ACTIVE and DISC connections will be returned.

    .EXAMPLE
        Get-RemoteRdpSession  -computername $(Get-AdComputer -filter * | select-object -exp name ) 

    .EXAMPLE
        Get-RemoteRdpSession  -computername ("server1", "server2") -state DISC  
       
    .NOTES
        Author: paolofrigo@gmail.com, https://www.scriptinglibrary.com
    #>
    
    [CmdletBinding()]
 
    [OutputType([int])]
    Param
    (        
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [string[]]
        $computername,

        [Parameter(Mandatory = $false, Position = 1 )]
        [ValidateSet("Active", "Disc")]
        [string]
        $state       
    )
    Begin {
        $tab = New-RdpSessionTable
        $counter = 1
        $total = $computername.Length
    }
    Process {
        foreach ($hostname in $computername) {   
            Write-Progress -Activity "Get-RemoteRdpSession" -Status "Querying RDP Session on $hostname" -PercentComplete (($counter / $total) * 100) 
            if (Test-Connection -ComputerName $hostname -Quiet -Count 1){
                $result = query session /server:$hostname
                $rows = $result -split "`n"            
                foreach ($row in $rows) {                
                    if ($state) {
                        $regex = $state
                    }
                    else {
                        $regex = "Disc|Active"
                    }
                    
                    if ($row -NotMatch "services|console" -and $row -match $regex) {
                        $session = $($row -Replace ' {2,}', ',').split(',')            
                        $newRow = $tab.NewRow()
                        $newRow["COMPUTERNAME"] = $hostname
                        $newRow["USERNAME"] = $session[1]
                        $newRow["ID"] = $session[2]
                        $newRow["STATE"] = $session[3]
                        $tab.Rows.Add($newRow)
                    }
                }
            }
            $counter += 1
        }
    }
    End {
        return $tab
    }
}

# ----------------
# Generate report
# ----------------

# Get today's date for the report
$Date = Get-Date -UFormat "%Y-%m-%d %H %M %S %p"

# Create report using the Get-RemoteRdpSession function and all ADComputer object whose OperatingSystem contains "server"
$Report = Get-RemoteRdpSession -computername $(Get-ADComputer -Filter {OperatingSystem -like "*server*"} | Select-Object -ExpandProperty Name)

# ----------------------------------------------------------------------------------------------------------
# Output report to csv

# Set the export location and file name of the audit report
$ExportPath     = "C:\Temp"
$ExportFileName = "Get Server RDP Sessions $Date.csv"

# Export the report to a csv file
$Report | Sort-Object COMPUTERNAME | Export-Csv -Path "$ExportPath\$ExportFileName" -NoTypeInformation

# ----------------------------------------------------------------------------------------------------------
# Output report to email
<# This email section is commented out so it is not in use.

# Email parameters
$Subject = "SERVER RDP SESSIONS REPORT - " + $Date
$SmtpServer = "smtp-relay.contoso.com"
$EmailFrom = "RDPSessionReport@contoso.com"
$EmailTo = "admin@contoso.com"

# Sort the report by COMPUTERNAME and convert it to a string so it can be emailed in the body of the email
$ReportForEmail = $Report | Sort COMPUTERNAME | Out-String

# Send email of the report
Send-MailMessage `
    -To $emailTo `
    -From $emailFrom `
    -Subject $Subject `
    -Body $ReportForEmail `
    -Port 587 `
    -SmtpServer $SmtpServer `
    -DeliveryNotificationOption OnSuccess,OnFailure,Delay
#>