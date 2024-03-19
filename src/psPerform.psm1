function Invoke-PerformanceRefactoring {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $FilePath
    )

    # Import rule functions dynamically
    $RuleFunctions = Get-ChildItem -Path "$PSScriptRoot/Rules/*.ps1" -ErrorAction SilentlyContinue
    foreach ($rule in $RuleFunctions) {
        . $rule.FullName
    }

    # Parse the script file
    $scriptContent = Get-Content -Path $FilePath -Raw
    $tokens = $null
    $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseInput($scriptContent, [ref]$tokens, [ref]$errors)

    # Initialize findings collection
    $allFindings = @()

    # Invoke each rule function
    foreach ($functionName in (Get-ChildItem -Path 'Function:\Invoke-*')) {
        $ruleFindings = & $functionName.Name -Tokens $tokens -Ast $ast
        $allFindings += $ruleFindings
    }

    # Return all findings
    return $allFindings
}

Export-ModuleMember -Function Invoke-PerformanceRefactoring
