function Invoke-DetectInvokeWebRequestRule {
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
        ($node.GetCommandName() -eq 'Invoke-WebRequest' -or $node.GetCommandName() -eq 'Invoke-RestMethod')
    }, $true) | ForEach-Object {
        $findings += [PSScriptAnalyzer.RuleRecord]::new(
            "DetectInvokeWebRequestRule",
            $_.Extent,
            "Consider replacing `Invoke-WebRequest` or `Invoke-RestMethod` with a `[System.Net.HttpWebRequest]::Create` template for finer control over API calls.",
            "Warning",
            "PSUseHttpWebRequestForAPICalls"
        )
    }

    return $findings
}

Export-ModuleMember -Function Invoke-DetectInvokeWebRequestRule
