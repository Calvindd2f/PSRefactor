function Invoke-SuppressOutputRule {
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
    $Ast.FindAll({
        param($node)
        $node -is [System.Management.Automation.Language.CommandAst] -or
        $node -is [System.Management.Automation.Language.RedirectionAst] -or
        $node -is [System.Management.Automation.Language.CastExpressionAst]
    }, $true) | ForEach-Object {
        $node = $_
        if ($node -is [System.Management.Automation.Language.CommandAst]) {
            $commandName = $node.GetCommandName()
            if ($commandName -eq 'Out-Null') {
                $findings += [PSScriptAnalyzer.RuleRecord]::new(
                    "SuppressOutputRule",
                    $node.Extent,
                    "Consider assigning output to `$null` for better performance instead of piping to Out-Null.",
                    "Warning",
                    "PSAvoidUsingCmdletOutput"
                )
            }
        } elseif ($node -is [System.Management.Automation.Language.RedirectionAst] -and
                $node.Right.Extent.Text -eq '$null') {
            $findings += [PSScriptAnalyzer.RuleRecord]::new(
                "SuppressOutputRule",
                $node.Extent,
                "Consider assigning output to `$null` for better performance instead of redirecting to `$null`.",
                "Warning",
                "PSAvoidUsingCmdletOutput"
            )
        } elseif ($node -is [System.Management.Automation.Language.CastExpressionAst] -and
                $node.StaticType -eq [void]) {
            $findings += [PSScriptAnalyzer.RuleRecord]::new(
                "SuppressOutputRule",
                $node.Extent,
                "Consider assigning output to `$null` for better performance instead of casting to [void].",
                "Warning",
                "PSAvoidUsingCmdletOutput"
            )
        }
    }

    return $findings
}

Export-ModuleMember -Function Invoke-SuppressOutputRule