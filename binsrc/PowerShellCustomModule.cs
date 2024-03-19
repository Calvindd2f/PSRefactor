using System;
using System.IO;
using System.Management.Automation;
using System.Text.RegularExpressions;

namespace PowerShellCustomModule
{
    [Cmdlet(VerbsDiagnostic.Analyze, "ScriptCustomRules")]
    public class AnalyzeScriptCustomRulesCmdlet : PSCmdlet
    {
        [Parameter(Mandatory = true, ValueFromPipeline = true)]
        public string[] ScriptPaths { get; set; }

        [Parameter()]
        public SwitchParameter ApplyFixes { get; set; }

        protected override void ProcessRecord()
        {
            foreach (var path in ScriptPaths)
            {
                try
                {
                    string scriptContent = File.ReadAllText(path);
                    string originalContent = scriptContent;

                    // Analyze and possibly refactor script content based on rules
                    scriptContent = AnalyzeAndRefactorScript(scriptContent);

                    // If ApplyFixes is true and changes were made, write back to the file
                    if (ApplyFixes && !scriptContent.Equals(originalContent))
                    {
                        File.WriteAllText(path, scriptContent);
                        WriteObject($"Refactored script: {path}");
                    }
                    else
                    {
                        WriteObject($"Analyzed script with no changes applied: {path}");
                    }
                }
                catch (Exception ex)
                {
                    WriteError(new ErrorRecord(ex, "ErrorProcessingScript", ErrorCategory.InvalidOperation, path));
                }
            }
        }

        private string AnalyzeAndRefactorScript(string scriptContent)
        {
            // Rule: Avoid Write-Host
            scriptContent = Regex.Replace(scriptContent, @"\bWrite-Host\b", "[System.Console]::WriteLine");

            // Rule: String Addition
            // Note: Real implementation may require syntax tree analysis.
            scriptContent = Regex.Replace(scriptContent, @"(\$[a-zA-Z0-9_]+) \+= ('.*')", @"$1 = $1 + $2");

            return scriptContent;
        }
    }
}
