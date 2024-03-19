Describe "DetectPotentialParallelProcessingRule Tests" {
    Context "Testing scripts that should trigger the DetectPotentialParallelProcessingRule" {
        It "Detects loops that might benefit from parallel processing" {
            $scriptContent = @"
1..10 | ForEach-Object {
    Start-Sleep -Seconds 1
}
"@            
            $violations = Invoke-ScriptAnalyzer -ScriptDefinition $scriptContent -IncludeRule 'DetectPotentialParallelProcessingRule'
            $violations.Count | Should -BeGreaterThan 0
            $violations.RuleName | Should -Contain 'DetectPotentialParallelProcessingRule'
        }
    }

    Context "Testing scripts that already utilize parallel processing" {
        It "Does not flag scripts using ForEach-Object -Parallel" {
            $scriptContent = @"
1..10 | ForEach-Object -Parallel {
    Start-Sleep -Seconds 1
} -ThrottleLimit 10
"@            
            $violations = Invoke-ScriptAnalyzer -ScriptDefinition $scriptContent -IncludeRule 'DetectPotentialParallelProcessingRule'
            $violations.Count | Should -Be 0
        }
    }
}
