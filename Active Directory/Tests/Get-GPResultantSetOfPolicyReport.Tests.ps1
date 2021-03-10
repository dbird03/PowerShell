#Requires -Module @{ ModuleName = 'Pester'; RequiredVersion = '4.10.1 ' }

# Load the Get-GPResultantSetOfPolicyReport function
$here = $PSScriptRoot
$sut = Split-Path $here -Parent
. $sut\Get-GPResultantSetOfPolicyReport.ps1

Describe "Get-GPResultantSetOfPolicyReport" {
    It "Should work like a compiled cmdlet" {
        (Get-Command Get-GPResultantSetOfPolicyReport | Select-Object CmdletBinding) | Should -BeTrue
    }
    Context "Parameters" {
        It "User parameter should exist"  {
            Get-Command Get-GPResultantSetOfPolicyReport | Should -HaveParameter User
        }
        It "User parameter should be of Type String"  {
            Get-Command Get-GPResultantSetOfPolicyReport | Should -HaveParameter User -Type String
        }
        It "User parameter should be mandatory"  {
            Get-Command Get-GPResultantSetOfPolicyReport | Should -HaveParameter User -Mandatory
        }
        It "Computer parameter should exist"  {
            Get-Command Get-GPResultantSetOfPolicyReport | Should -HaveParameter Computer
        }
        It "Computer parameter should be of Type String"  {
            Get-Command Get-GPResultantSetOfPolicyReport | Should -HaveParameter Computer -Type String
        }
        It "Computer parameter should be mandatory"  {
            Get-Command Get-GPResultantSetOfPolicyReport | Should -HaveParameter Computer -Mandatory
        }
        It "Path parameter should exist"  {
            Get-Command Get-GPResultantSetOfPolicyReport | Should -HaveParameter Path
        }
        It "Path parameter should be of Type String"  {
            Get-Command Get-GPResultantSetOfPolicyReport | Should -HaveParameter Path -Type String
        }
        It "Path parameter should not be mandatory"  {
            Get-Command Get-GPResultantSetOfPolicyReport | Should -HaveParameter Path -Not -Mandatory
        }
        It "Comment parameter should exist"  {
            Get-Command Get-GPResultantSetOfPolicyReport | Should -HaveParameter Comment
        }
        It "Comment parameter should be of Type String"  {
            Get-Command Get-GPResultantSetOfPolicyReport | Should -HaveParameter Comment -Type String
        }
        It "Comment parameter should not be mandatory"  {
            Get-Command Get-GPResultantSetOfPolicyReport | Should -HaveParameter Comment -Not -Mandatory
        }
    }
    Context "Process" {
        It "Should produce an error if the export path is greater than 260 characters" -Pending {
        }
    }
    Context "Output" {
        It "Should produce an HTML file" -Pending {
        }
        It "Should save the file in the current directory if not using the Path parameter" -Pending {
        }
        It "Should save the file in the Path parameter's value if using the Path parameter" -Pending {
        }
        It "Should have the date in the file name" -Pending {
        }
        It "Should have the User parameter's value in the file name" -Pending {
        }
        It "Should have the Computer parameter's value in the file name" -Pending {
        }
        It "Should have the Comment parameter's value in the file name if using the Comment parameter" -Pending {
        }
    }
}