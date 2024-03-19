Describe "AvoidWriteHostRule Tests" {
    Context "Testing scripts that should trigger the AvoidWriteHostRule" {
        It "Detects use of Write-Host" {
            $scriptContent = @"
Write-Host "Hello, World!"
"@            
            $violations = Invoke-ScriptAnalyzer -ScriptDefinition $scriptContent -IncludeRule 'AvoidWriteHostRule'
            $violations.Count | Should -BeGreaterThan 0
            $violations.RuleName | Should -Contain 'AvoidWriteHostRule'
        }
    }

    Context "Testing scripts that use [System.Console]::WriteLine() which do not trigger the AvoidWriteHostRule" {
        It "Allows the use of [System.Console]::WriteLine()" {
            $scriptContent = @"
[System.Console]::WriteLine("Hello, World!")
"@            
            $violations = Invoke-ScriptAnalyzer -ScriptDefinition $scriptContent -IncludeRule 'AvoidWriteHostRule'
            $violations.Count | Should -Be 0
        }
    }
}
