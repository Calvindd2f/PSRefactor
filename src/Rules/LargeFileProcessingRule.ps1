function Invoke-LargeFileProcessingRule {
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
    $cmdletNames = @('Get-Content', 'Set-Content', 'Import-Csv', 'Export-Csv')
    $ast | ForEach-Object {
        if ($_ -is [System.Management.Automation.Language.CommandAst]) {
            $commandName = $_.GetCommandName()
            if ($commandName -and $cmdletNames -contains $commandName) {
                $findings += [PSScriptAnalyzer.RuleRecord]::new(
                    "LargeFileProcessingRule",
                    $_.Extent,
                    "For large files, consider replacing `$commandName` with direct .NET API calls like `[System.IO.File]::ReadAllLines` or `[System.IO.File]::WriteAllLines` for better performance.",
                    "Warning",
                    "PSAvoidSlowCmdletsForLargeFiles"
                )
            }
        }
    }

    return $findings
}

Export-ModuleMember -Function Invoke-LargeFileProcessingRule
