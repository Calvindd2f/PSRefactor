Describe "AvoidCmdletPipelineWrappingRule Tests" {
    Context "Testing scripts that should trigger the AvoidCmdletPipelineWrappingRule" {
        It "Detects unnecessary wrapping of cmdlet pipelines" {
            $scriptContent = @"
$result = Get-Process | Where-Object { $_.CPU -gt 100 }
$result | Sort-Object CPU
"@            
            $violations = Invoke-PerformanceRefactoring -ScriptDefinition $scriptContent -IncludeRule 'AvoidCmdletPipelineWrappingRule'
            $violations.Count | Should -BeGreaterThan 0
            $violations.RuleName | Should -Contain 'AvoidCmdletPipelineWrappingRule'
        }
    }

    Context "Testing scripts that use a single, fluent pipeline which do not trigger the AvoidCmdletPipelineWrappingRule" {
        It "Allows efficient use of cmdlet pipelines" {
            $scriptContent = @"
Get-Process | Where-Object { $_.CPU -gt 100 } | Sort-Object CPU
"@            
            $violations = Invoke-PerformanceRefactoring -ScriptDefinition $scriptContent -IncludeRule 'AvoidCmdletPipelineWrappingRule'
            $violations.Count | Should -Be 0
        }
    }
}
