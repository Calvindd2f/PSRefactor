Describe "LargeFileProcessingRule Tests" {
    Context "Testing cmdlets that should trigger the LargeFileProcessingRule" {
        It "Detects use of Get-Content for large files" {
            $scriptContent = @"
Get-Content 'largefile.txt'
"@            
            $violations = Invoke-ScriptAnalyzer -ScriptDefinition $scriptContent -IncludeRule 'LargeFileProcessingRule'
            $violations.Count | Should -BeGreaterThan 0
            $violations.RuleName | Should -Contain 'LargeFileProcessingRule'
        }

        It "Detects use of Set-Content for large files" {
            $scriptContent = @"
Set-Content 'largefile.txt' -Value $content
"@            
            $violations = Invoke-ScriptAnalyzer -ScriptDefinition $scriptContent -IncludeRule 'LargeFileProcessingRule'
            $violations.Count | Should -BeGreaterThan 0
            $violations.RuleName | Should -Contain 'LargeFileProcessingRule'
        }
    }

    Context "Testing direct .NET API calls that do not trigger the LargeFileProcessingRule" {
        It "Allows direct .NET API calls for handling large files" {
            $scriptContent = @"
[System.IO.File]::ReadAllLines('largefile.txt')
[System.IO.File]::WriteAllLines('largefile.txt', $content)
"@            
            $violations = Invoke-ScriptAnalyzer -ScriptDefinition $scriptContent -IncludeRule 'LargeFileProcessingRule'
            $violations.Count | Should -Be 0
        }
    }
}
