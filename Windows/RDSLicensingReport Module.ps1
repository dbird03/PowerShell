<#
CimClasses
----------
Win32_TSLicenseServer
Win32_TSLicenseKeyPack
Win32_TSIssuedLicense
Win32_TSLicenseReportFailedPerUserSummaryEntry
Win32_TSLicenseReportFailedPerUserEntry
Win32_TSLicenseReportPerDeviceEntry
Win32_TSLicenseReportEntry
Win32_TSLicenseReportSummaryEntry
Win32_TSLicenseReport
#>

function Get-RDSLicenseReport {
<#
.SYNOPSIS
Gets RDS license report data.
.DESCRIPTION
This command uses CIM to gets RDS license report data from RDS servers.
.PARAMETER ComputerName
The name of the server(s) with the RD Licensing role installed.
.PARAMETER ReportType
The type of report to generate. Acceptable values are "Summary" and "IssuedLicenses".
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Summary","Issued")]
        [string]$ReportType
    )
    
    begin {
    }
    
    process {

        foreach ($Computer in $ComputerName) {

            switch ($ReportType) {
                "Summary" {
                    $LicenseKeyPacks = Get-CimInstance -ComputerName $Computer -ClassName Win32_TSLicenseKeyPack |
                                       Sort-Object ProductVersion
                        foreach ($LicenseKeyPack in $LicenseKeyPacks) {
                            $Output = [PSCustomObject][Ordered]@{
                                                                 'ComputerName'=$Computer
                                                                 'TypeAndModel'=$LicenseKeyPack.TypeAndModel
                                                                 'License Program'=$LicenseKeyPack.KeyPackType
                                                                 'Total Licenses'=$LicenseKeyPack.TotalLicenses
                                                                 'Available'=$LicenseKeyPack.AvailableLicenses
                                                                 'Issued'=$LicenseKeyPack.IssuedLicenses
                                                                 'Expiry Date'=$LicenseKeyPack.ExpirationDate
                                                                 'Keypack ID'=$LicenseKeyPack.KeyPackId
                                                                }
                            Write-Output $Output
                        }#End foreach ($LicenseKeyPack in $LicenseKeyPacks)
                }#End "Summary"

                "Issued" {
                    $IssuedLicenses = Get-CimInstance -ComputerName $Computer -ClassName Win32_TSIssuedLicense |
                                      Sort-Object IssueDate -Descending
                        foreach ($IssuedLicense in $IssuedLicenses) {
                            $Output = [PSCustomObject][Ordered]@{
                                                                 'ComputerName'=$Computer
                                                                 'Expires On'=$IssuedLicense.ExpirationDate
                                                                 'Issued On'=$IssuedLicense.IssueDate
                                                                 'License Status'=$IssuedLicense.LicenseStatus -replace "0","Unknown" -replace "1","Temporary" -replace "2","Active" -replace "3","Upgrade" -replace "4","Revoked" -replace "5","Pending" -replace "6","Concurrent"
                                                                 'Issued To Computer'=$IssuedLicense.sIssuedToComputer
                                                                 'Issued To User'=$IssuedLicense.sIssuedToUser
                                                                }
                            Write-Output $Output
                        }#End foreach ($IssuedLicensed in $IssuedLicenses)
                }# End "Issued"

                Default {
                }#End Default

            }#End switch ($ReportType)

        }#End foreach ($Computer in $ComputerName)

    }#End process
    
    end {
    }
}

function Get-RDSLicenseReportOld {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$ComputerName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Summary","Issued")]
        [string]$ReportType
    )
    
    begin {
    }
    
    process {
        switch ($ReportType) {
            "Summary" {
                $Report = Get-CimInstance -ComputerName $ComputerName -ClassName Win32_TSLicenseKeyPack |
                          Sort-Object ProductVersion |
                          Select-Object @{name='ProductVersion';expression={$_.ProductVersion}},
                                        @{name='TypeAndModel';expression={$_.TypeAndModel}},
                                        @{name='License Program';expression={$_.KeyPackType -replace "0","Unknown" -replace "1","Retail Purchase" -replace "2","Volume Purchase" -replace "3","Concurrent License" -replace "4","Temporary" -replace "5","Open License" -replace "6","Built-in" -replace "8","Built-in OverUsed"}},
                                        @{name='Total Licenses';expression={$_.TotalLicenses}},
                                        @{name='Available';expression={$_.AvailableLicenses}},
                                        @{name='Issued';expression={$_.IssuedLicenses}},
                                        @{name='Expiry Date';expression={$_.ExpirationDate}},
                                        @{name='Keypack ID';expression={$_.KeyPackId}}
                Write-Output $Report
            }#End "Summary"

            "Issued" {
                $Report = Get-CimInstance -ComputerName $ComputerName -ClassName Win32_TSIssuedLicense |
                          Sort-Object IssueDate -Descending |
                          Select-Object @{name='Expires On';expression={$_.ExpirationDate}},
                                        @{name='Issued On';expression={$_.IssueDate}},
                                        @{name='License Status';expression={$_.LicenseStatus -replace "0","Unknown" -replace "1","Temporary" -replace "2","Active" -replace "3","Upgrade" -replace "4","Revoked" -replace "5","Pending" -replace "6","Concurrent"}},
                                        @{name='Issued To Computer';expression={$_.sIssuedToComputer}},
                                        @{name='Issued To User';expression={$_.sIssuedToUser}}
                Write-Output $Report
            }# End "Issued"

            Default {

            }#End Default

        }#End switch $ReportType

        
    }#End process
    
    end {
    }
}

function Find-StaleLicenses {
<#
.DESCRIPTION
    A future function to compare issued licenses to users in Active Directory to find stale licenses.
#>
    [CmdletBinding()]
    param (
        
    )
    
    begin {
    }
    
    process {
    }
    
    end {
    }
}
function Get-RDSLicensingReportSummary {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $ComputerName
    )

    $ReportSummary = Get-CimInstance -ComputerName $ComputerName -ClassName Win32_TSLicenseKeyPack |
                     Sort-Object ProductVersion |
                     Select-Object @{name='ProductVersion';expression={$_.ProductVersion}},
                                   @{name='TypeAndModel';expression={$_.TypeAndModel}},
                                   @{name='License Program';expression={$_.KeyPackType -replace "0","Unknown" -replace "1","Retail Purchase" -replace "2","Volume Purchase" -replace "3","Concurrent License" -replace "4","Temporary" -replace "5","Open License" -replace "6","Built-in" -replace "8","Built-in OverUsed"}},
                                   @{name='Total Licenses';expression={$_.TotalLicenses}},
                                   @{name='Available';expression={$_.AvailableLicenses}},
                                   @{name='Issued';expression={$_.IssuedLicenses}},
                                   @{name='Expiry Date';expression={$_.ExpirationDate}},
                                   @{name='Keypack ID';expression={$_.KeyPackId}}

    Write-Output $ReportSummary
}

function Get-RDSLicensingIssuedLicense {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $ComputerName    
    )

    $IssuedLicenses = Get-CimInstance -ComputerName $ComputerName -ClassName Win32_TSIssuedLicense |
                      Sort-Object IssueDate -Descending |
                      Select-Object @{name='Expires On';expression={$_.ExpirationDate}},
                                    @{name='Issued On';expression={$_.IssueDate}},
                                    @{name='License Status';expression={$_.LicenseStatus -replace "0","Unknown" -replace "1","Temporary" -replace "2","Active" -replace "3","Upgrade" -replace "4","Revoked" -replace "5","Pending" -replace "6","Concurrent"}},
                                    @{name='Issued To Computer';expression={$_.sIssuedToComputer}},
                                    @{name='Issued To User';expression={$_.sIssuedToUser}}

    Write-Output $IssuedLicenses
}