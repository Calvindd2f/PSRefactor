function Invoke-DetectPotentialParallelProcessingRule {
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
        $node -is [System.Management.Automation.Language.StatementBlockAst] -and
        $node.Statements.Count -gt 0 -and
        $node.Statements[0] -is [System.Management.Automation.Language.PipelineAst]
    }, $true) | ForEach-Object {
        $pipelineAst = $_.Statements[0]
        if ($pipelineAst.PipelineElements[0] -is [System.Management.Automation.Language.CommandAst] -and
            $pipelineAst.PipelineElements[0].GetCommandName() -match 'ForEach-Object|Where-Object') {
            $findings += @{
                RuleName = "DetectPotentialParallelProcessingRule"
                Extent = $_.Extent.Text
                Message = "Detected loops that might benefit from parallel processing. Consider using `Parallel.ForEach` in .NET or `ForEach-Object -Parallel` in PowerShell 7+."
                Severity = "Information"
                Recommendation = "PSUseParallelProcessing"
            }
        }
    }

    return $findings
}
