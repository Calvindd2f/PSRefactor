function Invoke-AvoidCmdletPipelineWrappingRule {
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
        $node -is [System.Management.Automation.Language.PipelineAst] -and
        $node.PipelineElements.Count -eq 1 -and
        $node.PipelineElements[0] -is [System.Management.Automation.Language.CommandExpressionAst]
    }, $true) | ForEach-Object {
        $findings += @{
            RuleName = "AvoidCmdletPipelineWrappingRule"
            Extent = $_.Extent.Text
            Message = "Consider rewriting the pipeline to avoid unnecessary wrapping of cmdlets. A single, fluent pipeline is preferred for readability and performance."
            Severity = "Warning"
            Recommendation = "PSAvoidCmdletPipelineWrapping"
        }
    }

    return $findings
}
