<#
.SYNOPSIS
    Emails a DFSR backlog report
.DESCRIPTION
    Emails a DFSR backlog report
.NOTES
    Author: David Bird
    Created: March 27, 2020
    Last Updated: March 30, 2020
#>

# Load Get-SWDFSRBacklog function
Function Get-SWDFSRBacklog {
<#
.Synopsis
    Will return the count of items in the DFSR-backlog for each replicated folder specified.
.DESCRIPTION
    Will return the count of items in the DFSR-backlog for each replicated folder specified.
.EXAMPLE
    Get-SWDFSRBacklog -Threshold 50

    Will return numbor of items in the DFSR backlog for each folder that has a backlog of more than 50 items.
.EXAMPLE
    Get-SWDFSRBacklog -FolderName "Folder1", "Folder2"

    RGName : Folder1
    RFName : Folder1
    SMem   : Server01
    RMem   : Server02
    Count  : 0

    RGName : Folder1
    RFName : Folder1
    SMem   : Server02
    RMem   : Server01
    Count  : 0

    RGName : Folder2
    RFName : Folder1
    SMem   : Server01
    RMem   : Server02
    Count  : 0

    RGName : Folder2
    RFName : Folder1
    SMem   : Server02
    RMem   : Server01
    Count  : 0

    Will return the number of items in the backlog for the replicated folders Folder1 and Folder2.
    .LINK
    http://blog.simonw.se
#>
    [Cmdletbinding()]
    Param
    (
        [String]
        $DomainName = (Select-Object -InputObject $([System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()) -ExpandProperty Name),
        [String[]]
        $FolderName,
        [Int]
        $Threshold = 0
    )
    Begin
    {
        $Param = @{
            DomainName = $DomainName
            ErrorAction = 'Stop'
        }
        If( $PSBoundParameters.ContainsKey('FolderName') )
        {
            $Param.FolderName = $FolderName
        }
        $Folders = Get-DfsReplicatedFolder @Param
    }
    Process
    {
        foreach ($Folder in $Folders)
        {
            Write-Verbose -Message "Processing replicated folder $($Folder.FolderName)"
            $Members = $(Get-DfsrMember -GroupName $Folder.GroupName)
            foreach($Member in $Members)
            {
                $Partners = $Members | Where {$_ -ne $Member}
                Foreach ($Partner in $Partners)
                {
                    Write-Verbose -Message "Querying backlog between $($Member.ComputerName) and $($Partner.ComputerName)"
                    Try
                    {
                        # Read Verbose stream and ignore output stream
                        $VerboseMessage = $($Null = Get-DfsrBacklog -GroupName $Folder.GroupName -FolderName $Folder.FolderName -SourceComputerName $Member.ComputerName -DestinationComputerName $Partner.ComputerName -ErrorAction Stop -Verbose) 4>&1
                    }
                    Catch
                    {
                        Write-Warning -Message "Failed to query backlog between $($Member.ComputerName) and $($Partner.ComputerName)"
                        Continue
                    }
                    if ($VerboseMessage -Like "No backlog for the replicated folder named `"$($Folder.FolderName)`"")
                    {
                        $BacklogCount = 0
                    }
                    else
                    {
                        Try
                        {
                            $BacklogCount = [int]$($VerboseMessage -replace "The replicated folder has a backlog of files. Replicated folder: `"$($Folder.FolderName)`". Count: (\d+)",'$1')
                        }
                        Catch
                        {
                            Write-Warning -Message $_.Exception.Message
                            Continue
                        }
                    }
                    if( $BacklogCount -ge $Threshold )
                    {
                        [PSCustomObject]@{
                            RGName = $Folder.GroupName
                            RFName = $Folder.FolderName
                            SMem = $Member.ComputerName
                            RMem = $Partner.ComputerName
                            Count = $BacklogCount
                        }
                    }
                    else
                    {
                        Write-Verbose -Message "Backlogcount of $BacklogCount is below the threshold: $Threshold between $($Member.ComputerName) and $($Partner.ComputerName)"
                    }
                }
            }
        }
    }
}

# Get all DFSR Folders
$DFSRFolders = Get-DfsReplicatedFolder #| Where-Object {$_.FolderName -eq "Users"}

# Clear the $BacklogResults variable
$BacklogResults = $null

# Enumerate through each DFSR Folder
foreach ($DFSRFolder in $DFSRFolders) {
    $BacklogResults += Get-SWDFSRBacklog -FolderName $DFSRFolder.FolderName -Verbose
}
Write-Verbose $BacklogResults

# Convert $BacklogResults to HTML as a string so it can be sent in an email body
$EmailBody = $BacklogResults | ConvertTo-Html | Out-String
Write-Verbose $EmailBody

# Send email
$MailMessage = @{
    To                         = "admin@contoso.com"
    From                       = "PowerShell@contoso.com"
    Subject                    = "DFS Replication Report"
    Body                       = $EmailBody
    BodyAsHtml                 = $True
    Port                       = "587"
    SmtpServer                 = "smtp-relay.contoso.com"
}
Send-MailMessage @MailMessage