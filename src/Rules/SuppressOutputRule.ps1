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
        $node -is [System.Management.Automation.Language.TypeExpressionAst]
    }, $true) | ForEach-Object {
        $node = $_
        $finding = $null
        if ($node -is [System.Management.Automation.Language.CommandAst]) {
            $commandName = $node.GetCommandName()
            if ($commandName -eq 'Out-Null') {
                $finding = @{
                    RuleName = "SuppressOutputRule"
                    Extent = $node.Extent.Text
                    Message = "Consider assigning output to `$null` for better performance instead of piping to Out-Null."
                    Severity = "Warning"
                    Recommendation = "PSAvoidUsingCmdletOutput"
                }
            }
        } elseif ($node -is [System.Management.Automation.Language.RedirectionAst] -and
                  $node.Right.Extent.Text -eq '$null') {
            $finding = @{
                RuleName = "SuppressOutputRule"
                Extent = $node.Extent.Text
                Message = "Consider assigning output to `$null` for better performance instead of redirecting to `$null`."
                Severity = "Warning"
                Recommendation = "PSAvoidUsingCmdletOutput"
            }
        } elseif ($node -is [System.Management.Automation.Language.TypeExpressionAst] -and
                  $node.StaticType -eq [void]) {
            $finding = @{
                RuleName = "SuppressOutputRule"
                Extent = $node.Extent.Text
                Message = "Consider assigning output to `$null` for better performance instead of casting to [void]."
                Severity = "Warning"
                Recommendation = "PSAvoidUsingCmdletOutput"
            }
        }

        if ($finding) {
            $findings += $finding
        }
    }

    return $findings
}
