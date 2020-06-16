function Get-UserProfileStatus {
<#
.SYNOPSIS
    Checks the Active Directory status of a user profile on a computer.
.DESCRIPTION
    This cmdlet gets the user profiles on a computer and compares them to Active Directory to find terminated users.

    This script assumes all user profiles are Active Directory user accounts and not local accounts. For example, if there was a local 'COMPUTER\Administrator' account,
    this script would compare it against 'CONTOSO.COM\Administrator' and report on this value.
.EXAMPLE
    PS C:\> Get-UserProfileStatus -ComputerName WIN10
    Looks at the user profiles on computer WIN10 and compares them to Active Directory to report their status.

    PS C:\> Get-UserProfileStatus -ComputerName WIN10 -Verbose | Where-Object {$_.FoundInActiveDirectory -eq 'Yes'} | Sort-Object -Descending LastWriteTime
    Looks at the user profiles on computer WIN10 and compares them to Active Directory to report their status, filters only Active users, and sorts them by LastWriteTime.
.NOTES
    Created: September 26, 2019
    Author: David Bird
#>
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]    
        [string[]]$ComputerName = $env:COMPUTERNAME
    )
    
    begin {
    }
    
    process {
        foreach ($Computer in $ComputerName) {
            # Get the user profile directories on the computer
            Write-Verbose "Getting user profiles on $Computer"
            $ComputerProfiles = Get-ChildItem -Path "\\$Computer\c$\Users"

            # Check each user profile directory against Active Directory
            Write-Verbose "Checking user profiles on $Computer"
            foreach ($ComputerProfile in $ComputerProfiles) {
                # Check if the user exists in Active Directory and add the value to the FoundInActiveDirectory property
                if ($ADUser = Get-ADUser -Filter { SamAccountName -eq $ComputerProfile.Name } -Properties *) {
                    Write-Verbose "$ComputerProfile found in Active Directory"
                    $FoundInActiveDirectory = 'Yes'
                }
                else {
                    Write-Verbose "$ComputerProfile NOT found in Active Directory"
                    $FoundInActiveDirectory = 'No'
                }

                $Result = [PSCustomObject][Ordered]@{
                    Computer = $Computer
                    Name = $ComputerProfile.Name
                    LastWriteTime = $ComputerProfile.LastWriteTime
                    FoundInActiveDirectory = $FoundInActiveDirectory
                    Department = $ADUser.Department
                    JobTitle = $ADUser.Title
                    Description = $ADUser.Description
                }

                Write-Output $Result
            }#End foreach ($ComputerProfile in $ComputerProfiles)
        }#End foreach ($Computer in $ComputerName)
    }#End process
    
    end {
    }
}