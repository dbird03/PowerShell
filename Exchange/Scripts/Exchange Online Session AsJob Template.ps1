<#
.SYNOPSIS
    Template for running jobs in an Exchange Online session.
.DESCRIPTION
    Exchange Online Sessions run in no language mode which means you can't use variables, operators, and some commands such as
    ForEach-Object in the -ScriptBlock parameter of the Invoke-Command cmdlet.

    This template assumes you have already connected to Exchange Online.
.NOTES
    Created: November 8, 2019
    Author: David Bird
#>
$ExchangeOnlineSession = Get-PSSession | Where-Object {($_.ConfigurationName -eq 'Microsoft.Exchange') -and ($_.ComputerName -eq 'outlook.office365.com')}
Invoke-Command -Session $ExchangeOnlineSession -ScriptBlock {COMMAND GOES HERE} -AsJob -JobName "EXOJob"