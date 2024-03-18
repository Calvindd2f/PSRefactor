function Optimize-ScriptContent {
    param (
        [Parameter(Mandatory = $true)]
        [string]$scriptPath,

        [Parameter(Mandatory = $false)]
        [bool]$applyChanges = $false
    )

    # Read the script content as a single string
    $scriptContent = Get-Content -Path $scriptPath -Raw

    # Regex patterns to identify different $null casting usages
    $assignToNullPattern = '^\s*\$null\s*='
    $castingPattern = '\[void\]|\s>\s*\$null|\s\|\sOut-Null'

    # Filter the lines where changes are suggested
    $linesToChange = $scriptContent | Where-Object { $_ -match $castingPattern -and -not ($_ -match $assignToNullPattern) }

    # Display the lines where changes are suggested
    if ($linesToChange.Count -gt 0) {
        "Found lines that could be optimized by assigning output to `\$null` instead of casting:"
        $linesToChange | ForEach-Object { "`t$_" }

        if ($applyChanges) {
            # Apply changes by replacing the lines with optimized versions
            $newScriptContent = $scriptContent -replace $castingPattern, '$null'
            Set-Content -Path $scriptPath -Value $newScriptContent
            "Changes applied successfully."
        } else {
            "To apply changes, set the `applyChanges` parameter to `$true`."
        }
    } else {
        "No changes needed. All `$null` usages are already optimal."
    }

    # Regex pattern to identify wrapped cmdlet pipelines
    $wrappedPipelinePattern = 'ForEach-Object.*?{.*?\|.*?Export-Csv.*?}'

    # Check for wrapped pipelines
    if ($scriptContent -match $wrappedPipelinePattern) {
        $patternsToOptimize += $Matches[0]
    }

    # Display the patterns where optimization is suggested
    if ($patternsToOptimize.Count -gt 0) {
        "Found instances where cmdlet pipelines are unnecessarily wrapped inside another pipeline, which may lead to performance issues:"
        $patternsToOptimize | ForEach-Object { "`t$_`n" }
    } else {
        "No wrapped cmdlet pipeline patterns found that need optimization, or the script does not contain direct cases."
    }

    # Regex pattern to identify for-loops that contain function calls
    $loopWithFunctionCallPattern = 'for\s*\(.+\)\s*{[^{}]*\b[A-Za-z0-9_\-]+\s+\$[^{}]+[^{}]*}'

    # Track loops that might need optimization
    $loopsToOptimize = @()

    # Check for for-loops with function calls
    if ($scriptContent -match $loopWithFunctionCallPattern) {
        $loopsToOptimize += $Matches[0]
    }

    # Display the loops where optimization is suggested
    if ($loopsToOptimize.Count -gt 0) {
        "Found for-loops with function calls that might be optimized by moving the loop inside the function:"
        $loopsToOptimize | ForEach-Object { "`t$_`n" }
    } else {
        "No optimization needed for for-loops with function calls, or no direct cases were found."
    }

    # Track lines to suggest changes for
    $linesToChange = @()

    # Regex pattern to identify Write-Host usage
    $writeHostPattern = 'Write-Host'

    foreach ($line in $scriptContent) {
        # Check if the line is using Write-Host
        if ($line -match $writeHostPattern) {
            $linesToChange += $line
        }
    }

    # Display the lines where changes are suggested
    if ($linesToChange.Count -gt 0) {
        "Found lines that could be optimized by replacing Write-Host with Write-Verbose or [Console]::WriteLine():"
        $linesToChange | ForEach-Object { "`t$_" }
    } else {
        "No changes needed. Write-Host is not used or already replaced with preferred methods."
    }
}
# Usage example:
#Optimize-ScriptContent -scriptPath "C:\Path\To\YourScript.ps1" -applyChanges $true

Function Optimize-Script-LargeFileHandling {
    # Path to the PowerShell script you want to scan
    $scriptPath = "C:\Path\To\YourScript.ps1"

    # Read the script content
    $scriptContent = Get-Content -Path $scriptPath

    # Track lines to suggest changes for
    $linesToOptimizeForFileReading = @()
    $linesToOptimizeForWebDownload = @()

    # Regex patterns to identify inefficient patterns
    $fileReadingPattern = 'Get-Content\s+\$.*\s+\|\s+Where-Object'
    $webDownloadPattern = 'Invoke-WebRequest'

    foreach ($line in $scriptContent) {
        # Check for inefficient file reading operations
        if ($line -match $fileReadingPattern) {
            $linesToOptimizeForFileReading += $line
        }

        # Check for inefficient web download operations
        if ($line -match $webDownloadPattern) {
            $linesToOptimizeForWebDownload += $line
        }
    }

    # Display the lines where changes are suggested
    if ($linesToOptimizeForFileReading.Count -gt 0) {
        "Found lines that could be optimized by using [System.IO.StreamReader] for large file operations:"
        $linesToOptimizeForFileReading | ForEach-Object { "`t$_" }
    }

    if ($linesToOptimizeForWebDownload.Count -gt 0) {
        "Found lines that could be optimized by using [System.Net.Http.HttpClient] for web download operations:"
        $linesToOptimizeForWebDownload | ForEach-Object { "`t$_" }
    }

    if ($linesToOptimizeForFileReading.Count -eq 0 -and $linesToOptimizeForWebDownload.Count -eq 0) {
        "No changes needed. All file and web download operations are already using optimal methods."
    }
}

Function Optimize-Script-StringConcatenation {
    param (
        [string]$scriptPath
    )

    # Read the script content
    $scriptContent = Get-Content -Path $scriptPath

    # Track lines to suggest changes for
    $linesToChange = @()

    # Regex pattern to identify string concatenation using the += operator
    $concatPattern = '\s*\$.*\s*\+=\s*".*"\s*'

    foreach ($line in $scriptContent) {
        # Check if the line is using += for string concatenation
        if ($line -match $concatPattern) {
            $linesToChange += $line
        }
    }

    # Display the lines where changes are suggested
    if ($linesToChange.Count -gt 0) {
        "Found lines that could be optimized by using the -join operator for string concatenation:"
        $linesToChange | ForEach-Object { "`t$_" }
    } else {
        "No changes needed. All string concatenations are already using optimal methods."
    }
}

Function Optimize-Script-ArrayAddition {
    param (
        [string]$scriptPath
    )

    # Read the script content
    $scriptContent = Get-Content -Path $scriptPath

    # Track lines to suggest changes for
    $linesToAddMethod = @()
    $linesToPlusEqual = @()

    # Regex patterns to identify different array addition methods
    $addMethodPattern = '\.Add\('
    $plusEqualPattern = '\+=\s'

    foreach ($line in $scriptContent) {
        # Check if the line is using .Add(..) method for list addition
        if ($line -match $addMethodPattern) {
            $linesToAddMethod += $line
        }

        # Check if the line is using += operator for array addition
        if ($line -match $plusEqualPattern) {
            $linesToPlusEqual += $line
        }
    }

    # Display the lines where changes are suggested
    if ($linesToAddMethod.Count -gt 0 -or $linesToPlusEqual.Count -gt 0) {
        "Found lines that could be optimized by using PowerShell explicit assignment (foreach-object loop):"

        if ($linesToAddMethod.Count -gt 0) {
            "Recommend replacing .Add(..) method calls with foreach-object loop for Lists:"
            $linesToAddMethod | ForEach-Object { "`t$_" }
        }

        if ($linesToPlusEqual.Count -gt 0) {
            "Recommend replacing `+=` operator with foreach-object loop for Arrays:"
            $linesToPlusEqual | ForEach-Object { "`t$_" }
        }
    } else {
        "No changes needed. All array additions are already using optimal methods."
    }
}



function Send-WebRequest {
    param(
        [string]$ScriptPath,
        [bool]$ApplyChanges
    )

    $scriptContent = Get-Content -Path $ScriptPath -Raw

    # Define the new function
    $newFunction = @"
function New-WebRequest {
    param(
        [string]$Url,
        [string]$OutPath
    )

    $CHUNK_SIZE = 1MB
    $request = [System.Net.HttpWebRequest]::Create($Url)
    $request.Method = "GET"
    $response = $request.GetResponse()

    using ($responseStream = $response.GetResponseStream(),
           $fs = [System.IO.File]::OpenWrite($OutPath)) {
        $buffer = New-Object byte[] $CHUNK_SIZE
        while (($read = $responseStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
            $fs.Write($buffer, 0, $read)
        }
    }

    $response.Close()
}
"@

    # Replace occurrences of Invoke-WebRequest, iwr, and curl with New-WebRequest
    $scriptContent = $scriptContent -replace 'Invoke-WebRequest|iwr|curl', 'New-WebRequest'

    # Add a test to check if the replacement is working correctly
    $testScript = @"
# Test the replacement
if ((Test-Path "$env:TEMP\Agent_Uninstaller.zip") -and (Test-reIWR1 -iterationCount 1) -eq (Test-NewWebRequest -iterationCount 1)) {
    Write-Host "Replacement is working correctly."
} else {
    Write-Host "Replacement is not working correctly."
}
"@

    # Apply the changes if specified
    if ($ApplyChanges) {
        $scriptContent = $scriptContent -replace '# BEGIN: abpxx6d04wxr', "# BEGIN: abpxx6d04wxr`n$newFunction"
        $scriptContent = $scriptContent -replace '# END: abpxx6d04wxr', "# END: abpxx6d04wxr`n$testScript"
        Set-Content -Path $ScriptPath -Value $scriptContent
    }

    $scriptContent
}

#region tests:
function Test1 {
    param($iterationCount = 10)
    
    $ms = (Measure-Command {
        for ($i = 0; $i -lt $iterationCount; $i++) {
            Invoke-WebRequest -Uri "https://s3.amazonaws.com/assets-cp/assets/Agent_Uninstaller.zip" -OutFile "$env:TEMP"
        }
    }).TotalMilliseconds
    
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()

    return $ms
}
function Test2 {
    param($iterationCount = 10)
    
    $ms = (Measure-Command {
        for ($i = 0; $i -lt $iterationCount; $i++) {
            $url = "https://s3.amazonaws.com/assets-cp/assets/Agent_Uninstaller.zip"
            $outPath = Join-Path $PWD.Path "Agent_Uninstaller.zip"

            $CHUNK_SIZE = 1MB
            $request = [System.Net.HttpWebRequest]::Create($url)
            $request.Method = "GET"
            $response = $request.GetResponse()
            $responseStream = $response.GetResponseStream()
            $fs = [System.IO.File]::OpenWrite($outPath)
            $buffer = New-Object byte[] $CHUNK_SIZE
            while (($read = $responseStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
                $fs.Write($buffer, 0, $read)
            }
            $fs.Close()
            $responseStream.Close()
            $response.Close()
        }
    }).TotalMilliseconds
    
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()

    return $ms
}

$results = @{}
$tests = @('Test1', 'Test2')
foreach ($test in $tests) {
    $results[$test.Name] = @()
    for ($i = 0; $i -lt 10; $i++) {
        $results[$test.Name] += & $test
    }
}

# Write out the results as a CSV file
$csvContent = $results | ConvertTo-Csv -NoTypeInformation
$csvContent | Out-File -FilePath "$env:TEMP\results.csv"
$csvContent
#endregion tests:


# The `Send-WebRequest` function replaces occurrences of `Invoke-WebRequest`, `iwr`, and `curl` with a new function `New-WebRequest`. It also adds a test to check if the replacement is working correctly. The function accepts two parameters: `$ScriptPath` and `$ApplyChanges`. The `$ScriptPath` parameter specifies the path to the script file to be modified, and the `$ApplyChanges` parameter specifies whether to apply the changes to the script file.
# This script downloads two large files using HTTP GET requests and measures how long it takes to download each file using the original `Invoke-WebRequest` and the new `New-WebRequest` functions. It then writes the results to a CSV file.
























<# PARRALEL PROCESSING #>
<#
Start-ThreadJob -ScriptBlock { Read-Host 'Say hello'; Write-Warning 'Warning output' } -StreamingHost $Host
Receive-Job -Id 7
# Download multiple files at the same time
$baseUri = 'https://github.com/PowerShell/PowerShell/releases/download'
$files = @(
    @{
        Uri = "$baseUri/v7.3.0-preview.5/PowerShell-7.3.0-preview.5-win-x64.msi"
        OutFile = 'PowerShell-7.3.0-preview.5-win-x64.msi'
    },
    @{
        Uri = "$baseUri/v7.3.0-preview.5/PowerShell-7.3.0-preview.5-win-x64.zip"
        OutFile = 'PowerShell-7.3.0-preview.5-win-x64.zip'
    },
    @{
        Uri = "$baseUri/v7.2.5/PowerShell-7.2.5-win-x64.msi"
        OutFile = 'PowerShell-7.2.5-win-x64.msi'
    },
    @{
        Uri = "$baseUri/v7.2.5/PowerShell-7.2.5-win-x64.zip"
        OutFile = 'PowerShell-7.2.5-win-x64.zip'
    }
)

$jobs = @()

foreach ($file in $files) {
    $jobs += Start-ThreadJob -Name $file.OutFile -ScriptBlock {
        $params = $using:file
        Invoke-WebRequest @params
    }
}
Write-Host "Downloads started..."
Wait-Job -Job $jobs

foreach ($job in $jobs) {
    $result = Receive-Job -Job $job
    # Process the result here
}
#>