function Invoke-ArrayAdditionRule {
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
    $ast | ForEach-Object {
        if ($_ -is [System.Management.Automation.Language.AssignStatementAst] -and
            $_.Left -is [System.Management.Automation.Language.VariableExpressionAst] -and
            $_.Operator -eq [System.Management.Automation.Language.TokenKind]::PlusEquals) {
                $variableName = $_.Left.VariablePath.UserPath
                $findings += [PSScriptAnalyzer.RuleRecord]::new(
                    "ArrayAdditionRule",
                    $_.Extent,
                    "Consider using a generic list or a similar data structure instead of adding to an array with '+=' operator for better performance.",
                    "Warning",
                    "PSAvoidUsingArrayAddition"
                )
        }
    }

    return $findings
}

Export-ModuleMember -Function Invoke-ArrayAdditionRule
