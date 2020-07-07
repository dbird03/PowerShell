function Connect-ExchangeOnPremSession {
<#
.SYNOPSIS
    Starts a remote PowerShell session to an on-prem Exchange server.
.DESCRIPTION
    Starts a remote PowerShell session to an on-prem Exchange server.
.PARAMETER COMPUTERNAME
    The name of the on-prem Exchange server.
.PARAMETER CREDENTIAL
    The credentials used to establish the remote session.
.EXAMPLE
    PS C:\> Connect-ExchangeOnPremSession -ComputerName "EXCH.contoso.com" -Credential "contoso.com\administrator"
    Starts a remote PowerShell session on an on-prem Exchange server named EXCH.contoso.com using the credential contoso.com\administrator.
.LINK
    https://docs.microsoft.com/en-us/powershell/exchange/exchange-online/connect-to-exchange-online-powershell/connect-to-exchange-online-powershell?view=exchange-ps
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,
                   HelpMessage="Enter the FQDN of the on-prem Exchange server (ex: exch.contoso.com)")]
        [ValidateNotNullOrEmpty()]
        [string]$ComputerName,
        [PSCredential]$Credential
    )
    
    begin {
    }
    
    process {
        $params = @{
            ConfigurationName = "Microsoft.Exchange"
            ConnectionUri     = "http://$ComputerName/PowerShell/"
            Authentication    = "Kerberos"
            Credential        = $Credential
        }
        $ExchangeOnPremSession = New-PSSession @params
        Import-PSSession $ExchangeOnPremSession -DisableNameChecking
    }
    
    end {
    }
}

function Connect-ExchangeOnlineSession {
<#
.SYNOPSIS
    Starts a remote PowerShell session to Exchange Online.
.DESCRIPTION
    Starts a remote PowerShell session to Exchange Online.
.PARAMETER CREDENTIAL
    The credentials used to establish the remote session.
.EXAMPLE
    PS C:\> Connect-ExchangeOnlineSession -Credential "contoso.com\administrator"
    Starts a remote PowerShell session to Exchange Online using the credential contoso.com\administrator.
.LINK
    https://docs.microsoft.com/en-us/powershell/exchange/exchange-online/connect-to-exchange-online-powershell/connect-to-exchange-online-powershell?view=exchange-ps
#>
    [CmdletBinding()]
    param (
        [PSCredential]$Credential
    )
    
    begin {
    }

    process {
        $params = @{
            ConfigurationName = "Microsoft.Exchange"
            ConnectionUri     = "https://outlook.office365.com/powershell-liveid/"
            Authentication    = "Basic"
            AllowRedirection  = $true
            Credential       = $Credential
        }
        $ExchangeOnlineSession = New-PSSession @params
        Import-PSSession $ExchangeOnlineSession -DisableNameChecking
    }
    
    end {
    }
}

function Connect-AzureADSession {
<#
.SYNOPSIS
    Starts a remote PowerShell session to Azure Active Directory.
.DESCRIPTION
    Starts a remote PowerShell session to Azure Active Directory.
.PARAMETER CREDENTIAL
    The credentials used to establish the remote session.
.EXAMPLE
    PS C:\> Connect-AzureADSession -Credential "contoso.com\administrator"
    Starts a remote PowerShell session to Azure Active Directory using the credential contoso.com\administrator.

#>
    [CmdletBinding()]
    param (
        [PSCredential]$Credential
    )
    
    begin {
    }
    
    process {
        if (Get-Module -ListAvailable -Name "MSOnline") {
            Connect-MsolService -Credential $Credential
        }
        else {
            Write-Output "Required module is NOT installed"
        }
    }
    
    end {
    }
}

function Connect-SharePointOnline {
<#
.SYNOPSIS
    Starts a remote PowerShell session to SharePoint Online.
.DESCRIPTION
    Starts a remote PowerShell session to SharePoint Online. To connect with MFA, do not use the -Credential parameter.
.PARAMETER CREDENTIAL
    The credentials used to establish the remote session. To connect with MFA, do not use this parameter.
.EXAMPLE
    PS C:\> Connect-SharePointOnline
    Starts a remote PowerShell session to SharePoint Online.
.LINK
    https://docs.microsoft.com/en-us/powershell/sharepoint/sharepoint-online/connect-sharepoint-online?view=sharepoint-ps
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,
                   HelpMessage="Enter the org name of your organization (ex: contoso if your Office 365 tenant is contoso-)")]
        [ValidateNotNullOrEmpty()]
        [string]$orgName,
        [PSCredential]$Credential
    )
    
    begin {
    }
    
    process {
        if (Get-Module -ListAvailable -Name Microsoft.Online.SharePoint.PowerShell) {
            $params = @{
                Url        = "https://$orgName-admin.sharepoint.com"
                Credential = $Credential
            }
            Connect-SPOService @params
        }
    }
    
    end {
    }
}

function Connect-O365SecurityAndComplianceSession {
<#
.SYNOPSIS
    Starts a remote PowerShell session to the Office 365 Security & Compliance Center.
.DESCRIPTION
    Starts a remote PowerShell session to the Office 365 Security & Compliance Center.
.PARAMETER CREDENTIAL
    The credentials used to establish the remote session.
.EXAMPLE
    PS C:\> Connect-O365SecurityAndComplianceSession
    Starts a remote PowerShell session to the Office 365 Security & Compliance Center
.LINK
    https://docs.microsoft.com/en-us/powershell/exchange/connect-to-scc-powershell?view=exchange-ps
#>
    [CmdletBinding()]
    param (
        [PSCredential]$Credential
    )
    
    process {
        $params = @{
            ConfigurationName = "Microsoft.Exchange"
            ConnectionUri     = "https://ps.compliance.protection.outlook.com/powershell-liveid/"
            Authentication    = "Basic"
            AllowRedirection  = $true
            Credential        = $Credential
        }
        $O365SecurityAndComplianceSession = New-PSSession @params
        # I don't know why Import-Module or the -Global switch is needed to make this work, but the powershell.org link below
        # is where I found this solution. If you don't use this, the commands in the remote session do not work.
        # https://powershell.org/forums/topic/connect-to-exchange-function-in-module-not-persistent/
        Import-Module (Import-PSSession $O365SecurityAndComplianceSession -DisableNameChecking) -Global -DisableNameChecking -Force
    }

}