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
    $ast | ForEach-Object {
        if ($_ -is [System.Management.Automation.Language.CommandExpressionAst] -and
            $_.Expression -is [System.Management.Automation.Language.PipelineAst]) {
            $pipeline = $_.Expression
            if ($pipeline.PipelineElements[0] -is [System.Management.Automation.Language.CommandAst]) {
                $commandName = $pipeline.PipelineElements[0].GetCommandName()
                if ($commandName -and (Get-Command $commandName -ErrorAction SilentlyContinue)) {
                    $findings += [PSScriptAnalyzer.RuleRecord]::new(
                        "SuppressOutputRule",
                        $pipeline.Extent,
                        "Consider suppressing the output of this command or using it more efficiently to enhance script performance.",
                        "Warning",
                        "PSAvoidUsingCmdletOutput"
                    )
                }
            }
        }
    }

    return $findings
}

Export-ModuleMember -Function Invoke-SuppressOutputRule
