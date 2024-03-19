function Invoke-AvoidWriteHostRule {
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
        $node -is [System.Management.Automation.Language.CommandAst] -and
        $node.GetCommandName() -eq 'Write-Host'
    }, $true) | ForEach-Object {
        $findings += [PSScriptAnalyzer.RuleRecord]::new(
            "AvoidWriteHostRule",
            $_.Extent,
            "Consider replacing `Write-Host` with `[System.Console]::WriteLine()` for better performance and flexibility.",
            "Warning",
            "PSAvoidUsingWriteHost"
        )
    }

    return $findings
}

Export-ModuleMember -Function Invoke-AvoidWriteHostRule
