$Date = Get-Date -UFormat "%Y-%m-%d %H %M %S %p"
$Mailboxes = Get-Mailbox -ResultSize Unlimited | Select-Object -Property Identity,displayName,primarySmtpAddress | Sort-Object -Property Identity
$ExternalForwardingRules = Get-ExternalForwardingInboxRules -Mailboxes $Mailboxes
$ExternalForwardingRules | Export-Csv "C:\Temp\ExternalForwardingRules $Date.csv" -NoTypeInformation