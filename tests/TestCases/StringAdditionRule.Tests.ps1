Describe "StringAdditionRule Tests" {
    Context "Testing string additions that should trigger the StringAdditionRule" {
        It "Detects inefficient string addition with '+' operator" {
            $scriptContent = @"
$name = "John"
$greeting = "Hello, " + $name + "!"
"@            
            $violations = Invoke-ScriptAnalyzer -ScriptDefinition $scriptContent -IncludeRule 'StringAdditionRule'
            $violations.Count | Should -BeGreaterThan 0
            $violations.RuleName | Should -Contain 'StringAdditionRule'
        }
    }

    Context "Testing string handling that does not trigger the StringAdditionRule" {
        It "Allows efficient string handling with `-join` operator" {
            $scriptContent = @"
$parts = @("Hello, ", "John", "!")
$greeting = $parts -join ''
"@            
            $violations = Invoke-ScriptAnalyzer -ScriptDefinition $scriptContent -IncludeRule 'StringAdditionRule'
            $violations.Count | Should -Be 0
        }
    }
}
