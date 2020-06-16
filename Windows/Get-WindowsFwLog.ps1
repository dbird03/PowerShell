function Get-WindowsFwLog {

<#PSScriptInfo
 
.VERSION 1.0
 
.GUID b5d5cab4-c73c-46c5-89e4-c4a6287c19c0
 
.AUTHOR Martin Norlunn
 
.COMPANYNAME
 
.COPYRIGHT
 
.TAGS Windows Firewall Log parser
 
.LICENSEURI
 
.PROJECTURI
 
.ICONURI
 
.EXTERNALMODULEDEPENDENCIES
 
.REQUIREDSCRIPTS
 
.EXTERNALSCRIPTDEPENDENCIES
 
.RELEASENOTES
 
 
.PRIVATEDATA
 
#>

<#
.SYNOPSIS
    Imports and parse the native Windows Advanced Firewall Log
 
.DESCRIPTION
    Imports and parse the native Windows Advanced Firewall Log.
    Stores entries in custom class, and generates several basic grouped by reports to quickly identify trends in the log.
    Can filter events based on start time, end time, or a custom searchstring.
 
.INPUTS
    System.DateTime
    System.String
 
.OUTPUTS
    Outputs a PSObject with five properties; Entries, GroupByAction, GroupByDestinationPort, GroupByProtocol, GroupBySourceIP
 
.EXAMPLE
    $Report = .\Get-WindowsFwLog.ps1 -Verbose
 
.EXAMPLE
    $Report = .\Get-WindowsFwLog.ps1 -SearchString "10.10.10.101"
 
.EXAMPLE
    $Report = .\Get-WindowsFwLog.ps1 -Start (Get-Date).AddMinutes(-10) -Verbose
 
.EXAMPLE
    $Report = .\Get-WindowsFwLog.ps1 -Start ([datetime]"2019.04.25 19:00:00") -End ([datetime]"2019.04.25 20:00:00")
 
.EXAMPLE
    $Report = .\Get-WindowsFwLog.ps1 -LogFile "C:\FWLogs\fwlog.log"
    $Report = "C:\FWLogs\fwlog.log" | .\Get-WindowsFwLog.ps1
 
.NOTES
    Author: Martin Norlunn
    Created: 25.04.2019
    Version: 1.0
#>
    #Requires -Version 5.0
    [Cmdletbinding()]
    [OutputType("PSObject")]
    Param
    (
        [parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$LogFile = "$env:SystemRoot\System32\LogFiles\Firewall\pfirewall.log",
        [ValidateNotNull()]
        [datetime]$Start,
        [ValidateNotNull()]
        [datetime]$End,
        [ValidateNotNullOrEmpty()]
        [string]$SearchString
    )

    Begin
    {
        class WindowsFwLogEntry
        {
            [datetime]$DateTime
            [string]$Action
            [string]$Protocol
            [IPAddress]$SourceIP
            [IPAddress]$DestinationIP
            [string]$SourcePort
            [string]$DestinationPort
            [string]$Size
            [string]$TcpFlags
            [string]$TcpSync
            [string]$TcpAck
            [string]$TcpWin
            [string]$IcmpType
            [string]$IcmpCode
            [string]$Info
            [string]$Path

            WindowsFwLogEntry ([string]$Raw)
            {
                $Parts = $Raw -split " "
                $this.DateTime = "$($Parts[0]) $($Parts[1])"
                $this.Action = $Parts[2]
                $this.Protocol = $Parts[3]
                $this.SourceIP = $Parts[4]
                $this.DestinationIP = $Parts[5]
                $this.SourcePort = $Parts[6]
                $this.DestinationPort = $Parts[7]
                $this.Size = $Parts[8]
                $this.TcpFlags = $Parts[9]
                $this.TcpSync = $Parts[10]
                $this.TcpAck = $Parts[11]
                $this.TcpWin = $Parts[12]
                $this.IcmpType = $Parts[13]
                $this.IcmpCode = $Parts[14]
                $this.Info = $Parts[15]
                $this.Path = $Parts[16]
            }
        }
    }

    Process
    {
        Write-Verbose -Message "Getting firewall log: $LogFile"
        $LogEntries = Get-Content -Path $LogFile | Select-Object -Skip 5

        if ($PSBoundParameters.ContainsKey("Start") -or $PSBoundParameters.ContainsKey("End") -or $PSBoundParameters.ContainsKey("SearchString"))
        {
            Write-Verbose -Message "Number of entries before filtering: $(($LogEntries | Measure-Object).Count)"
        }

        if ($PSBoundParameters.ContainsKey("SearchString"))
        {
            $LogEntries = $LogEntries | Select-String -Pattern $SearchString
        }

        $LogEntries = $LogEntries | ForEach-Object { [WindowsFwLogEntry]::new($_)}

        if ($PSBoundParameters.ContainsKey("Start"))
        {
            Write-Verbose -Message "Filtering log on start datetime: $Start"
            $LogEntries = $LogEntries | Where-Object DateTime -ge $Start
        }

        if ($PSBoundParameters.ContainsKey("End"))
        {
            Write-Verbose -Message "Filtering log on end datetime: $End"
            $LogEntries = $LogEntries | Where-Object DateTime -ge $End
        }

        if ($PSBoundParameters.ContainsKey("Start") -or $PSBoundParameters.ContainsKey("End") -or $PSBoundParameters.ContainsKey("SearchString"))
        {
            Write-Verbose -Message "Number of entries after filtering: $(($LogEntries | Measure-Object).Count)"
        }

        Write-Verbose -Message 'Generating grouped by reports'
        $GroupByAction = $LogEntries | Group-Object -Property Action | Sort-Object -Property Count -Descending
        $GroupByDestinationPort = $LogEntries | Group-Object -Property DestinationPort | Sort-Object -Property Count -Descending
        $GroupByProtocol = $LogEntries | Group-Object -Property Protocol | Sort-Object -Property Count -Descending
        $GroupBySourceIP = $LogEntries | Group-Object -Property SourceIP | Sort-Object -Property Count -Descending
    }

    End
    {
        New-Object -TypeName PSObject -Property @{
            Entries = $LogEntries
            GroupByAction = $GroupByAction
            GroupByDestinationPort = $GroupByDestinationPort
            GroupByProtocol = $GroupByProtocol
            GroupBySourceIP = $GroupBySourceIP
        }
    }
}