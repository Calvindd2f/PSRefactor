Describe "AvoidRepeatedFunctionCallsRule Tests" {
    Context "Testing scripts that should trigger the AvoidRepeatedFunctionCallsRule" {
        It "Detects repeated function calls" {
            $scriptContent = @"
function Get-Data {
    # Imagine this function fetches data from a web service
}
for ($i = 0; $i -lt 10; $i++) {
    $data = Get-Data
}
"@            
            $violations = Invoke-ScriptAnalyzer -ScriptDefinition $scriptContent -IncludeRule 'AvoidRepeatedFunctionCallsRule'
            $violations.Count | Should -BeGreaterThan 0
            $violations.RuleName | Should -Contain 'AvoidRepeatedFunctionCallsRule'
        }
    }

    Context "Testing scripts that optimize repeated function calls" {
        It "Does not flag optimized use of function calls" {
            $scriptContent = @"
function Get-Data {
    # Imagine this function fetches data from a web service
}
$data = Get-Data
for ($i = 0; $i -lt 10; $i++) {
    # Use $data without calling Get-Data again
}
"@            
            $violations = Invoke-ScriptAnalyzer -ScriptDefinition $scriptContent -IncludeRule 'AvoidRepeatedFunctionCallsRule'
            $violations.Count | Should -Be 0
        }
    }
}
