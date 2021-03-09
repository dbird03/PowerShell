#Requires -Module Pester

# Load the Get-GPResultantSetOfPolicyReport function
$here = $PSScriptRoot
$sut = Split-Path $here -Parent
. $sut\Get-GPResultantSetOfPolicyReport.ps1

Describe "Get-GPResultantSetOfPolicyReport" {
    Context "Parameters" {
        BeforeAll {
            Mock -CommandName Get-GPResultantSetOfPolicy -MockWith {
                Return 1
            }
        }
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
    Context "ContextName" {
        It "ItName" {
            Mock -CommandName Get-GPResultantSetOfPolicy -MockWith {
                Return 1
            }
            Get-GPResultantSetOfPolicyReport -User 'jsmith' -Computer 'jsmith-laptop' | Should -Be '1'
        }
    }
}