<#
.SYNOPSIS
    Sets CrowdStrike IP addresses in Windows Firewall rules
.DESCRIPTION
    This script sets CrowdStrike IP addresses as the RemoteAddress in Windows Firewall rules in a Group Policy GPO.
    
    This script assumes you have three (3) rules created in a single GPO. The three rules corresponds to the three groups of IP addresses
    CrowdStrike uses for their Commercial Cloud.

    Ex: CrowdStrike Commercial Cloud Term Servers (In)
        CrowdStrike Commercial Cloud LFO Download (In)
        CrowdStrike Commercial Cloud Streaming API (In)

    If CrowdStrike updates their IP address lists, simply update the arrays in this script and run the script to set the new IP addresses on
    the rules.
    
    Note: This script uses Set-NetFirewallRule which will set the RemoteAddress value of the rules with the IP addresses specified in the arrays.
    The set operation does NOT append the IP addresses specified in the arrays to the rules, therefore the IP addresses specified in the rules
    will be overwritten.
.NOTES
    Created: June 18, 2020
    Author: David Bird
#>

############################################################################################
# CrowdStrike Commercial Cloud IP Addresses                                                #
#                                                                                          #
# These IP addresses can be found in CrowdStrike's documentation or at the following link: #
# https://falcon.crowdstrike.com/support/documentation/65/cloud-ip-addresses               #
############################################################################################

$TermServerAddresses = @"
xxx.xxx.xxx.xxx
xxx.xxx.xxx.xxx
xxx.xxx.xxx.xxx
xxx.xxx.xxx.xxx
"@ -split "`n" | ForEach-Object { $_.trim() }

$LFODownloadAddresses = @"
yyy.yyy.yyy.yyy
yyy.yyy.yyy.yyy
yyy.yyy.yyy.yyy
yyy.yyy.yyy.yyy
"@ -split "`n" | ForEach-Object { $_.trim() }

$StreamingAPIAddresses = @"
zzz.zzz.zzz.zzz
zzz.zzz.zzz.zzz
zzz.zzz.zzz.zzz
zzz.zzz.zzz.zzz
"@ -split "`n" | ForEach-Object { $_.trim() }


#######################################################
# Specify Group Policy GPO and Windows Firewall Rules #
#######################################################
$GpoDomain = 'contoso.com'
$GpoName = 'Windows Firewall Policy'

$TermServerRule = 'CrowdStrike Commercial Cloud Term Servers (In)'
$LFODownloadRule = 'CrowdStrike Commercial Cloud LFO Download (In)'
$StreamingAPI = 'CrowdStrike Commercial Cloud Streaming API (In)'


#########################
# Update Firewall Rules #
#########################

# Open the GPO
Write-Verbose "Opening GPO: $GpoDomain\$GpoName" -Verbose
$GpoSession = Open-NetGPO -PolicyStore "$GpoDomain\$GpoName"

# Update Term Server IP addresses
Write-Verbose "Updating Rule: $TermServerRule" -Verbose
$TermServerParams = @{
    DisplayName    = $TermServerRule
    RemoteAddress  = $TermServerAddresses
    GPOSession     = $GpoSession
}
Set-NetFirewallRule @TermServerParams

# Update LFO Download IP Addresses
Write-Verbose "Updating Rule: $LFODownloadRule" -Verbose
$LFODownloadParams = @{
    DisplayName    = $LFODownloadRule
    RemoteAddress  = $LFODownloadAddresses
    GPOSession     = $GpoSession
}
Set-NetFirewallRule @LFODownloadParams

# Update Streaming API IP Addresses
Write-Verbose "Updating Rule: $StreamingAPI" -Verbose
$StreamingAPIParams = @{
    DisplayName    = $StreamingAPI 
    RemoteAddress  = $StreamingAPIAddresses
    GPOSession     = $GpoSession
}
Set-NetFirewallRule @StreamingAPIParams

# Save the GPO
Write-Verbose "Saving GPO: $GpoDomain\$GpoName" -Verbose
Save-NetGPO -GPOSession $GpoSession