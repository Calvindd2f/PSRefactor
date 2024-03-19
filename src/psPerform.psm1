# Ensure required modules are loaded
if (-not (Get-Module -ListAvailable -Name PSScriptAnalyzer)) {
    Install-Module -Name PSScriptAnalyzer -Scope CurrentUser
}
Import-Module PSScriptAnalyzer

# Define a helper function to load custom rules
function Import-CustomRule {
    param (
        [string]$Path
    )
    . $Path
}

# Load custom rules
$script:RulePath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$customRules = @(
    "SuppressOutputRule.ps1",
    "ArrayAdditionRule.ps1",
    "StringAdditionRule.ps1",
    "LargeFileProcessingRule.ps1",
    "AvoidWriteHostRule.ps1",
    "AvoidRepeatedFunctionCallsRule.ps1",
    "AvoidCmdletPipelineWrappingRule.ps1",
    "DetectInvokeWebRequestRule.ps1",
    "DetectPotentialParallelProcessingRule.ps1"
)

foreach ($rule in $customRules) {
    $fullPath = Join-Path -Path $script:RulePath -ChildPath "Rules\$rule"
    Import-CustomRule -Path $fullPath
}

# Optionally, register custom rules with PSScriptAnalyzer if you're extending it
# This might involve adding to its rule definitions or creating a new ruleset

Export-ModuleMember -Function 'Invoke-*' # Replace '*' with actual function names
