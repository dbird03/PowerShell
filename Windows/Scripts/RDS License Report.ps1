<#
.Synopsis
    Sends an email report of RDS license usage.
.DESCRIPTION
    Sends an email report of RDS license usage. This script should be copied locally to the RDS Licensing server
    and called in a Scheduled Task on the server.
.NOTES
    Author: David Bird
    Created: August 2, 2019
#>
# Variables
$TimeStamp = Get-Date -UFormat "%A, %B%e, %Y %r"

# User-defined variables
$RDSLicensingServer = "RDS01" # Server where the RDS Licenses are installed
$SmtpServer         = "smtp.contoso.com" # Smtp relay server used to send emails
$To                 = "admin@contoso.com" # Recipients that should receive the email report

# Get the installed licenses and issued licenses from the RDS Licensing server
$ReportSummary = Get-CimInstance -ComputerName $RDSLicensingServer -ClassName Win32_TSLicenseKeyPack | Sort-object ProductVersion | Select-Object  ProductVersion,TypeAndModel,@{name='License Program';expression={$_.KeyPackType -replace "0","Unknown" -replace "1","Retail Purchase" -replace "2","Volume Purchase" -replace "3","Concurrent License" -replace "4","Temporary" -replace "5","Open License" -replace "6","Built-in" -replace "8","Built-in OverUsed"}},@{name='Total Licenses';expression={$_.TotalLicenses}},@{name='Available';expression={$_.AvailableLicenses}},@{name='Issued';expression={$_.IssuedLicenses}},@{name='Expiry Date';expression={$_.ExpirationDate}},@{name='Keypack ID';expression={$_.KeyPackId}}
$IssuedLicenses = Get-CimInstance -ComputerName $RDSLicensingServer -ClassName Win32_TSIssuedLicense | Sort-Object IssueDate -Descending | Select-Object @{name='Expires On';expression={$_.ExpirationDate}},@{name='Issued On';expression={$_.IssueDate}},@{name='License Status';expression={$_.LicenseStatus -replace "0","Unknown" -replace "1","Temporary" -replace "2","Active" -replace "3","Upgrade" -replace "4","Revoked" -replace "5","Pending" -replace "6","Concurrent"}},@{name='Issued To Computer';expression={$_.sIssuedToComputer}},@{name='Issued To User';expression={$_.sIssuedToUser}}

# Convert the objects to HTML so they can be sent in the body of the email
$ReportSummaryHtml = $ReportSummary | ConvertTo-Html   
$IssuedLicensesHtml = $IssuedLicenses | ConvertTo-Html

# Create the body of the email (formatted in HTML)
$EmailBody = "
<h1>$RDSLicensingServer - RDS License Report</h1>
$TimeStamp
<br>
<h2>License Report Summary</h2>
$ReportSummaryHtml
<br>
<h2>License Usage</h2>
$IssuedLicensesHtml"

# Send email message
$MailMessage = @{
    To                         = $To
    From                       = "$RDSLicensingServer@contoso.com"
    Subject                    = "$RDSLicensingServer - RDS License Report - $TimeStamp"
    Body                       = $EmailBody
    BodyAsHtml                 = $True
    Port                       = "587"
    SmtpServer                 = $SmtpServer
}
Send-MailMessage @MailMessage