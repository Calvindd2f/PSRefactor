Describe "ArrayAdditionRule Tests" {
    Context "Testing array additions that should trigger the ArrayAdditionRule" {
        It "Detects inefficient array addition with '+=' operator" {
            $scriptContent = @"
$array = @()
1..10 | ForEach-Object { $array += $_ }
"@            
            $violations = Invoke-ScriptAnalyzer -ScriptDefinition $scriptContent -IncludeRule 'ArrayAdditionRule'
            $violations.Count | Should -BeGreaterThan 0
            $violations.RuleName | Should -Contain 'ArrayAdditionRule'
        }
    }

    Context "Testing array handling that does not trigger the ArrayAdditionRule" {
        It "Allows efficient array handling with generic list" {
            $scriptContent = @"
$list = New-Object System.Collections.Generic.List[object]
1..10 | ForEach-Object { $list.Add($_) }
"@            
            $violations = Invoke-ScriptAnalyzer -ScriptDefinition $scriptContent -IncludeRule 'ArrayAdditionRule'
            $violations.Count | Should -Be 0
        }
    }
}
