# Ensure Pester is installed
if (-not (Get-Module -ListAvailable -Name Pester)) {
    Install-Module -Name Pester -Scope CurrentUser -Force
}
Import-Module Pester -ErrorAction Stop

# Navigate to the tests directory
Push-Location -Path .\Tests

# Run Pester tests across all .Tests.ps1 files
Invoke-Pester -Output Detailed

# Return to the original directory
Pop-Location
