# Powershell-Refactor
Does various refactoring for some modules I use that are fairly slow. Refactoring logic is based off Microsoft Learn Powershell performance considerations. Trying to make a bit more modular but particularly last 2 are tough without human intervention.

------------------------------------------------------------

# Key Analysis
- **PowerShellModule**
- - Integration with PSScriptAnalyzer for default rule enforcement.
- - Custom rules focusing on performance:
- - - Suppressing output to improve script efficiency.
- - - Array addition optimizations to avoid costly operations.
- - - Efficient processing of large files to minimize resource consumption.
- - - String addition considerations for memory management.
- - - Discouraging the use of Write-Host for cleaner and more efficient output handling.
- - - Minimizing repeated calls to functions to improve execution speed.
- - - Avoiding the wrapping of cmdlet pipelines to streamline data flow and processing.
- **Binary Module Consideration**
- - Depending on the nature of the tasks performed by the module, a binary module written in C# might offer better performance, especially if operations are compute-intensive or require advanced data manipulation beyond the scope of PowerShell's optimized use cases.
Depending on the nature of the tasks performed by the module, a binary module written in C# might offer better performance, especially if operations are compute-intensive or require advanced data manipulation beyond the scope of PowerShell's optimized use cases.
Structure/Outline for the PowerShellModule Project
  
  
# Structure/Outline for the PowerShellModule Project

```plaintext
PowerShellModule/
│
├── src/
│   ├── PowerShellModule.psm1 - The main PowerShell module file.
│   └── Rules/ - Directory containing custom PSScriptAnalyzer rules.
│       ├── SuppressOutputRule.ps1
│       ├── ArrayAdditionRule.ps1
│       ├── StringAdditionRule.ps1
│       ├── LargeFileProcessingRule.ps1
│       ├── AvoidWriteHostRule.ps1
│       ├── RepeatedFunctionCallsRule.ps1
│       └── AvoidCmdletPipelineWrappingRule.ps1
│
├── tests/
│   ├── TestCases/ - Directory containing test scripts for each custom rule.
│   │   ├── SuppressOutputRule.Tests.ps1
│   │   ├── ArrayAdditionRule.Tests.ps1
│   │   ├── StringAdditionRule.Tests.ps1
│   │   ├── LargeFileProcessingRule.Tests.ps1
│   │   ├── AvoidWriteHostRule.Tests.ps1
│   │   ├── RepeatedFunctionCallsRule.Tests.ps1
│   │   └── AvoidCmdletPipelineWrappingRule.Tests.ps1
│   └── RunTests.ps1 - Script to run all tests and report findings.
│
└── README.md - Documentation on module usage and development guidelines.

```

### Structure
This module will load and register all the custom rules you've created for `PSScriptAnalyzer` to use. Each rule will be encapsulated in its own script file, which you've already developed. The module file will import these scripts and expose their functionalities as part of the module.

### Structure of `Module.psm1`
Your `Module.psm1` will:

1. Define a module manifest that outlines module metadata, dependencies, and exported members.
2. Load all custom rule scripts
3. Register custom rules with PSScriptAnalyzer (if applicable, depending on how you plan to integrate with PSScriptAnalyzer).


# Steps to Compile the Module
+ Import-Module `Module.psm1`
+ Try analyzing a script with `Invoke-ScriptAnalyzer` cmdlet to see if your custom rules are applied.

This setup provides a structured way to integrate custom rules into your PowerShell scripting environment, enhancing code quality and maintainability through static analysis with PSScriptAnalyzer.


--------------------------------------------------------------------------------

## Notice:

### C# version of module is not advised. It is not maintained and was more proof of concept. The major issue was AST and a look of guess work.