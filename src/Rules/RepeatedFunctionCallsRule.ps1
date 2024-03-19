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

    $ast.FindAll({
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

    $functionCallNames.GetEnumerator() | ForEach-Object {
        if ($_.Value -gt 1) {
            $findings += [PSScriptAnalyzer.RuleRecord]::new(
                "AvoidRepeatedFunctionCallsRule",
                $Ast.Extent,
                "Detected repeated calls to function `$_`. Consider optimizing by reusing results or refactoring.",
                "Warning",
                "PSAvoidRepeatedFunctionCalls"
            )
        }
    }

    return $findings
}

Export-ModuleMember -Function Invoke-AvoidRepeatedFunctionCallsRule
