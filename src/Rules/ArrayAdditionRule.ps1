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
    # Use FindAll to search for all instances of AssignmentStatementAst with a PlusEquals operator.
    $Ast.FindAll({
        param($node)
        $node -is [System.Management.Automation.Language.AssignmentStatementAst] -and
        $node.Operator -eq [System.Management.Automation.Language.TokenKind]::PlusEquals
    }, $true) | ForEach-Object {
        $variableName = $_.Left.VariablePath.UserPath
        # Ensure we're dealing with a variable and it's not $null (though checking against $null might not be strictly necessary in this context)
        if ($variableName -and $variableName -ne '$null') {
            $findings += [PSScriptAnalyzer.RuleRecord]::new(
                "ArrayAdditionRule",
                $_.Extent,
                "Consider using a List[T] and .Add(..) method instead of `+=` for better performance.",
                "Warning",
                "PSUseListAddInsteadOfArrayPlusEquals"
            )
        }
    }

    return $findings
}

Export-ModuleMember -Function Invoke-ArrayAdditionRule
