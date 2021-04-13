<#
.SYNOPSIS
    Get email addresses (both primary SMTP and aliases)
.DESCRIPTION
    This script gets email addresses from recipients and removes the SMTP: and smtp: prefixes.
.EXAMPLE
#>
$Recpients = Get-Recipient -RecipientType UserMailbox -ResultSize Unlimited
($Recpients.EmailAddresses | Where-Object {$_ -match "SMTP"}) -split "," -replace "SMTP:"