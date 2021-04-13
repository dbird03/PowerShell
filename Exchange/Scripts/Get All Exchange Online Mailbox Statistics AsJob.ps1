Invoke-Command -Session $ExchangeOnlineSession -ScriptBlock {Get-Mailbox -ResultSize Unlimited | Get-MailboxStatistics | Select-object -Property DisplayName,TotalItemSize,ItemCount,LastLogonTime} -AsJob -JobName "MailboxStatistics"