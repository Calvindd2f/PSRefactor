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
    $Ast.FindAll({
        param($node)
        $node -is [System.Management.Automation.Language.CommandAst] -and
        ($node.GetCommandName() -eq 'Invoke-WebRequest' -or $node.GetCommandName() -eq 'Invoke-RestMethod')
    }, $true) | ForEach-Object {
        $findings += @{
            RuleName = "DetectInvokeWebRequestRule"
            Extent = $_.Extent.Text
            Message = "Consider replacing `Invoke-WebRequest` or `Invoke-RestMethod` with a `[System.Net.HttpWebRequest]::Create` template for finer control over API calls."
            Severity = "Warning"
            Recommendation = "PSUseHttpWebRequestForAPICalls"
        }
    }

    return $findings
}
