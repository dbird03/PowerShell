<#
.SYNOPSIS
    Lists all of Windows and Software updates applied to a computer
.DESCRIPTION
    Lists all of Windows and Software updates applied to a computer uses the COM object Microsoft.Update.Session
.NOTES
    Source: https://social.technet.microsoft.com/wiki/contents/articles/4197.windows-how-to-list-all-of-the-windows-and-software-updates-applied-to-a-computer.aspx
#>
$Session = New-Object -ComObject "Microsoft.Update.Session"
$Searcher = $Session.CreateUpdateSearcher()

$historyCount = $Searcher.GetTotalHistoryCount()

$Searcher.QueryHistory(0, $historyCount) | Select-Object Date, Title, Description,@{name="Operation"; expression={switch($_.operation){
        1 {"Installation"}
        2 {"Uninstallation"}
        3 {"Other"}
    }}
} | Sort-Object Date