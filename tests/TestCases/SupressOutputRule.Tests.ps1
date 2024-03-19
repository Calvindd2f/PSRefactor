Describe "SuppressOutputRule Tests" {
    Context "Testing commands that should trigger the SuppressOutputRule" {
        It "Detects command output that is not suppressed or used" {
            $scriptContent = @"
Get-Process | Out-Null
Get-Date
"@            
            $violations = Invoke-PerformanceRefactoring -ScriptDefinition $scriptContent -IncludeRule 'SuppressOutputRule'
            $violations.Count | Should -BeGreaterThan 0
            $violations.RuleName | Should -Contain 'SuppressOutputRule'
        }
    }

    Context "Testing commands that do not trigger the SuppressOutputRule" {
        It "Allows commands where output is used or suppressed correctly" {
            $scriptContent = @"
Get-Process | Out-Null
$Date = Get-Date
"@            
            $violations = Invoke-PerformanceRefactoring -ScriptDefinition $scriptContent -IncludeRule 'SuppressOutputRule'
            $violations.Count | Should -Be 0
        }
    }
}
