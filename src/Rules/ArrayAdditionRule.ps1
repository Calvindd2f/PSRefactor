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
        # Ensure we're dealing with a variable and it's not $null
        if ($variableName -and $variableName -ne '$null') {
            $findings += @{
                RuleName = "ArrayAdditionRule"
                Extent = $_.Extent.Text
                Message = "Consider using a List[T] and .Add(..) method instead of `+=` for better performance."
                Severity = "Warning"
                Recommendation = "PSUseListAddInsteadOfArrayPlusEquals"
            }
        }
    }

    return $findings
}
