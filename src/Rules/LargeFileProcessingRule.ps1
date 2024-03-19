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
    $Ast | ForEach-Object {
        if ($_ -is [System.Management.Automation.Language.CommandAst]) {
            $commandName = $_.GetCommandName()
            if ($commandName -and $cmdletNames -contains $commandName) {
                $findings += @{
                    RuleName = "LargeFileProcessingRule"
                    Extent = $_.Extent.Text
                    Message = "For large files, consider replacing `$commandName` with direct .NET API calls like `[System.IO.File]::ReadAllLines` or `[System.IO.File]::WriteAllLines` for better performance."
                    Severity = "Warning"
                    Recommendation = "PSAvoidSlowCmdletsForLargeFiles"
                }
            }
        }
    }

    return $findings
}
