function Get-DotNetFrameworkVersion {
<#
.SYNOPSIS
    This script reports the various .NET Framework versions installed on the local or a remote computer.
.DESCRIPTION
    This script reports the various .NET Framework versions installed on the local or a remote computer.
.EXAMPLE
    PS C:\> Get-NetFrameworkVersion -ComputerName 'SRV01'
    Gets the .NET Framework version of the remote computer 'SRV01' 
.NOTES
    Script Name : Get-NetFrameworkVersion.ps1
    Description : This script reports the various .NET Framework versions installed on the local or a remote computer.
    Author : Martin Schvartzman
    Reference : https://msdn.microsoft.com/en-us/library/hh925568

    .NET Framework Versions and Build Numbers
    https://docs.microsoft.com/en-us/dotnet/framework/migration-guide/how-to-determine-which-versions-are-installed
#>

    param(
        # The original script only had [string]. This was changed to [string[]] to support arrays
        # since this function already had a foreach ($computer in $computername) construct.
        # The default value is the local computer.

        [string[]]$ComputerName = $env:COMPUTERNAME
    )

    $dotNetRegistry  = 'SOFTWARE\Microsoft\NET Framework Setup\NDP'
    $dotNet4Registry = 'SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full'
    $dotNet4Builds = @{
        '30319'  = @{ Version = [System.Version]'4.0'   ; }
        '378389' = @{ Version = [System.Version]'4.5'   ; Comment = 'All Windows operating systems' }
        '378675' = @{ Version = [System.Version]'4.5.1' ; Comment = 'Windows 8.1 and Windows Server 2012 R2' }
        '378758' = @{ Version = [System.Version]'4.5.1' ; Comment = 'All other Windows operating systems' }
        '379893' = @{ Version = [System.Version]'4.5.2' ; Comment = 'All Windows operating systems' }
        '380042' = @{ Version = [System.Version]'4.5'   ; Comment = 'and later with KB3168275 (Windows 7 SP1, Windows Vista SP2) or KB3168276 (Windows 8.1, Windows 8) or KB3166736 (Windows 8, Windows RT) or KB3166737 (Windows 7 SP1, Windows Server 2008 R2 SP1) rollup' }
        '393295' = @{ Version = [System.Version]'4.6'   ; Comment = 'Windows 10' }
        '393297' = @{ Version = [System.Version]'4.6'   ; Comment = 'All other Windows operating systems' }
        '394254' = @{ Version = [System.Version]'4.6.1' ; Comment = 'Windows 10 November Update systems' }
        '394271' = @{ Version = [System.Version]'4.6.1' ; Comment = 'All other Windows operating systems (including Windows 10)' }
        '394802' = @{ Version = [System.Version]'4.6.2' ; Comment = 'Windows 10 Anniversary Update and Windows Server 2016' }
        '394806' = @{ Version = [System.Version]'4.6.2' ; Comment = 'All other Windows operating systems (including other Windows 10 operating systems)' }
        '460798' = @{ Version = [System.Version]'4.7'   ; Comment = 'Windows 10 Creators Update' }
        '460805' = @{ Version = [System.Version]'4.7'   ; Comment = 'All other Windows operating systems (including other Windows 10 operating systems)' }
        '461308' = @{ Version = [System.Version]'4.7.1' ; Comment = 'Windows 10 Fall Creators Update and Windows Server, version 1709' }
        '461310' = @{ Version = [System.Version]'4.7.1' ; Comment = 'All other Windows operating systems (including other Windows 10 operating systems)' }
        '461808' = @{ Version = [System.Version]'4.7.2' ; Comment = 'Windows 10 April 2018 Update and Windows Server, version 1803' }
        '461814' = @{ Version = [System.Version]'4.7.2' ; Comment = 'All Windows operating systems other than Windows 10 April 2018 Update and Windows Server, version 1803' }
        '528040' = @{ Version = [System.Version]'4.8'   ; Comment = 'Windows 10 May 2019 Update and Windows 10 November 2019 Update' }
        '528049' = @{ Version = [System.Version]'4.8'   ; Comment = 'All other Windows operating systems (including other Windows 10 operating systems)' }
        '528209' = @{ Version = [System.Version]'4.8'   ; Comment = 'Windows 10 May 2020 Update' }
        '528372' = @{ Version = [System.Version]'4.8'   ; Comment = 'Windows 10 May 2020 Update and Windows 10 October 2020 Update' }
    }

    foreach($computer in $ComputerName)
    {
        if($regKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $computer))
        {
            if ($netRegKey = $regKey.OpenSubKey("$dotNetRegistry"))
            {
                foreach ($versionKeyName in $netRegKey.GetSubKeyNames())
                {
                    if ($versionKeyName -match '^v[123]') {
                        $versionKey = $netRegKey.OpenSubKey($versionKeyName)
                        $version = [System.Version]($versionKey.GetValue('Version', ''))
                        New-Object -TypeName PSObject -Property ([ordered]@{
                                ComputerName = $computer
                                Build = $version.Build
                                Version = $version
                                Comment = ''
                        })
                    }
                }
            }

            if ($net4RegKey = $regKey.OpenSubKey("$dotNet4Registry"))
            {
                if(-not ($net4Release = $net4RegKey.GetValue('Release')))
                {
                    $net4Release = 30319
                }
                New-Object -TypeName PSObject -Property ([ordered]@{
                        ComputerName = $Computer
                        Build = $net4Release
                        Version = $dotNet4Builds["$net4Release"].Version
                        Comment = $dotNet4Builds["$net4Release"].Comment
                })
            }
        }
    }
}