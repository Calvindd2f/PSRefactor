function Invoke-AvoidRepeatedFunctionCallsRule {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.Management.Automation.Language.Token[]]
        $Tokens,

        [Parameter(Mandatory)]
        [System.Management.Automation.Language.Ast[]]
        $Ast
    )

    $findings = @()
    $functionCallNames = @{}

    $Ast.FindAll({
        param($node)
        $node -is [System.Management.Automation.Language.CommandAst]
    }, $true) | ForEach-Object {
        $functionName = $_.GetCommandName()
        if (-not $functionCallNames.ContainsKey($functionName)) {
            $functionCallNames[$functionName] = 1
        } else {
            $functionCallNames[$functionName]++
        }
    }

    foreach ($functionCall in $functionCallNames.GetEnumerator()) {
        if ($functionCall.Value -gt 1) {
            $findings += @{
                RuleName = "AvoidRepeatedFunctionCallsRule"
                Extent = $Ast.Extent.Text
                Message = "Detected repeated calls to function `$(functionCall.Name)`. Consider optimizing by reusing results or refactoring."
                Severity = "Warning"
                Recommendation = "PSAvoidRepeatedFunctionCalls"
            }
        }
    }

    return $findings
}
