Describe "DetectInvokeWebRequestRule Tests" {
    Context "Testing scripts that should trigger the DetectInvokeWebRequestRule" {
        It "Detects use of Invoke-WebRequest" {
            $scriptContent = @"
Invoke-WebRequest -Uri 'https://api.example.com/data' -Method Get
"@            
            $violations = Invoke-ScriptAnalyzer -ScriptDefinition $scriptContent -IncludeRule 'DetectInvokeWebRequestRule'
            $violations.Count | Should -BeGreaterThan 0
            $violations.RuleName | Should -Contain 'DetectInvokeWebRequestRule'
        }

        It "Detects use of Invoke-RestMethod" {
            $scriptContent = @"
Invoke-RestMethod -Uri 'https://api.example.com/data' -Method Get
"@            
            $violations = Invoke-ScriptAnalyzer -ScriptDefinition $scriptContent -IncludeRule 'DetectInvokeWebRequestRule'
            $violations.Count | Should -BeGreaterThan 0
            $violations.RuleName | Should -Contain 'DetectInvokeWebRequestRule'
        }
    }

    Context "Testing scripts that use [System.Net.HttpWebRequest]::Create which do not trigger the DetectInvokeWebRequestRule" {
        It "Allows the use of [System.Net.HttpWebRequest]::Create for API calls" {
            $scriptContent = @"
$request = [System.Net.HttpWebRequest]::Create('https://api.example.com/data')
$request.Method = 'GET'
"@            
            $violations = Invoke-ScriptAnalyzer -ScriptDefinition $scriptContent -IncludeRule 'DetectInvokeWebRequestRule'
            $violations.Count | Should -Be 0
        }
    }
}
