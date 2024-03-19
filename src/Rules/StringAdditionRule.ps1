function Invoke-StringAdditionRule {
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
        $node -is [System.Management.Automation.Language.BinaryExpressionAst] -and
        $node.Operator -eq [System.Management.Automation.Language.TokenKind]::Plus -and
        $node.Left.StaticType -eq [string] -and
        $node.Right.StaticType -eq [string]
    }, $true) | ForEach-Object {
        $findings += @{
            RuleName = "StringAdditionRule"
            Extent = $_.Extent.Text
            Message = "Consider using the `-join` operator or the `[System.Text.StringBuilder]` class for string concatenation to improve performance."
            Severity = "Warning"
            Recommendation = "PSAvoidUsingStringAddition"
        }
    }

    return $findings
}
