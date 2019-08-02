<#
.Synopsis
    Sends an email report of RDS license usage.
.DESCRIPTION
    Sends an email report of RDS license usage.
#>

# User-defined variables
$RDSLicensingServer = "RDS01" # Server where the RDS Licenses are installed
$SmtpServer         = "smtp-relay.contoso.com" # Smtp relay server used to send emails

# Get the installed licenses and issued licenses from the RDS Licensing server
$ReportSummary = Get-CimInstance -ComputerName $RDSLicensingServer -ClassName Win32_TSLicenseKeyPack | Sort-object ProductVersion | Select-Object  ProductVersion,TypeAndModel,@{name='License Program';expression={$_.KeyPackType -replace "0","Unknown" -replace "1","Retail Purchase" -replace "2","Volume Purchase" -replace "3","Concurrent License" -replace "4","Temporary" -replace "5","Open License" -replace "6","Built-in" -replace "8","Built-in OverUsed"}},@{name='Total Licenses';expression={$_.TotalLicenses}},@{name='Available';expression={$_.AvailableLicenses}},@{name='Issued';expression={$_.IssuedLicenses}},@{name='Expiry Date';expression={$_.ExpirationDate}},@{name='Keypack ID';expression={$_.KeyPackId}}
$IssuedLicenses = Get-CimInstance -ComputerName $RDSLicensingServer -ClassName Win32_TSIssuedLicense | Sort-Object IssueDate -Descending | Select-Object @{name='Expires On';expression={$_.ExpirationDate}},@{name='Issued On';expression={$_.IssueDate}},@{name='License Status';expression={$_.LicenseStatus -replace "0","Unknown" -replace "1","Temporary" -replace "2","Active" -replace "3","Upgrade" -replace "4","Revoked" -replace "5","Pending" -replace "6","Concurrent"}},@{name='Issued To Computer';expression={$_.sIssuedToComputer}},@{name='Issued To User';expression={$_.sIssuedToUser}}

# Convert the objects to HTML so they can be sent in the body of the email
$ReportSummaryEmail = $ReportSummary | ConvertTo-Html   
$IssuedLicensesEmail = $IssuedLicenses | ConvertTo-Html

# Create the body of the email (formatted in HTML)
$EmailBody = "
$ReportSummaryEmail
<br>
$IssuedLicensesEmail"

# Send email message
$MailMessage = @{
    To                         = "admin@contoso.com"
    From                       = "$RDSLicensingServer@contoso.com"
    Subject                    = "RDS License Report"
    Body                       = $EmailBody
    BodyAsHtml                 = $True
    Port                       = "587"
    SmtpServer                 = $SmtpServer
}
Send-MailMessage @MailMessage
