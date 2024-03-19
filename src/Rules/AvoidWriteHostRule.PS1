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
    $Ast.FindAll({
        param($node)
        $node -is [System.Management.Automation.Language.CommandAst] -and
        $node.GetCommandName() -eq 'Write-Host'
    }, $true) | ForEach-Object {
        $findings += @{
            RuleName = "AvoidWriteHostRule"
            Extent = $_.Extent.Text
            Message = "Consider replacing `Write-Host` with `[System.Console]::WriteLine()` for better performance and flexibility."
            Severity = "Warning"
            Recommendation = "PSAvoidUsingWriteHost"
        }
    }

    return $findings
}
