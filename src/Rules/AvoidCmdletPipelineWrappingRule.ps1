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
    $ast.FindAll({
        param($node)
        $node -is [System.Management.Automation.Language.PipelineAst] -and
        $node.PipelineElements.Count -eq 1 -and
        $node.PipelineElements[0] -is [System.Management.Automation.Language.CommandExpressionAst]
    }, $true) | ForEach-Object {
        $findings += [PSScriptAnalyzer.RuleRecord]::new(
            "AvoidCmdletPipelineWrappingRule",
            $_.Extent,
            "Consider rewriting the pipeline to avoid unnecessary wrapping of cmdlets. A single, fluent pipeline is preferred for readability and performance.",
            "Warning",
            "PSAvoidCmdletPipelineWrapping"
        )
    }

    return $findings
}

Export-ModuleMember -Function Invoke-AvoidCmdletPipelineWrappingRule
