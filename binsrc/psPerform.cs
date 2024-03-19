using System;
using System.IO;
using System.Management.Automation;
using System.Management.Automation.Language;
using System.Collections.Generic;
using System.Text.RegularExpressions;

namespace psPerform
{
    [Cmdlet(VerbsDiagnostic.Test, "ScriptCustomRules")]
    public class InvokeScriptCustomRules  : PSCmdlet
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
                    Token[] tokens;
                    ParseError[] errors;
                    ScriptBlockAst scriptAst = Parser.ParseInput(scriptContent, out tokens, out errors);

                    if (errors.Length > 0)
                    {
                        WriteWarning($"Parse errors encountered in script {path}.");
                        continue; // Skip to the next file if there are parsing errors
                    }

                    // Perform the specific rule checks
                    CheckForArrayAddition(scriptAst);
                    CheckForCmdletPipelineWrapping(scriptAst);
                    CheckForRepeatedFunctionCalls(scriptAst, path);

                    // If ApplyFixes is true and changes were made, optionally refactor script content
                    if (ApplyFixes)
                    {
                        scriptContent = RefactorScriptContent(scriptContent);
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

       private void CheckForArrayAddition(ScriptBlockAst scriptAst)
       {
            // Find all instances of += operator in assignment statements
            var assignments = scriptAst.FindAll(ast => ast is AssignmentStatementAst assignment && assignment.Operator == TokenKind.PlusEquals, searchNestedScriptBlocks: true);

            foreach (AssignmentStatementAst assignment in assignments)
            {
                // This is a simplification. In reality, you'd also want to verify the left-hand variable is an array.
                var variableName = (assignment.Left as VariableExpressionAst)?.VariablePath.UserPath;
                if (!string.IsNullOrWhiteSpace(variableName))
                {
                    WriteWarning($"Consider using a List[T] and .Add method instead of `+=` for array `{variableName}` for better performance at line {assignment.Extent.StartLineNumber}.");
                }
            }
        }


        private void CheckForCmdletPipelineWrapping(ScriptBlockAst scriptAst)
        {
            var wrappedPipelines = scriptAst.FindAll(ast => 
                ast is PipelineAst pipelineAst && 
                pipelineAst.PipelineElements.Count == 1 &&
                pipelineAst.PipelineElements[0] is CommandExpressionAst, 
                searchNestedScriptBlocks: true);

            foreach (PipelineAst pipeline in wrappedPipelines)
            {
                string message = $"Consider rewriting the pipeline to avoid unnecessary wrapping of cmdlets at line {pipeline.Extent.StartLineNumber}. A single, fluent pipeline is preferred for readability and performance.";
                WriteWarning(message);
            }
        }


        private void CheckForRepeatedFunctionCalls(ScriptBlockAst scriptAst, string path)
        {
            var functionCallCounts = new Dictionary<string, int>();
            var functionCalls = scriptAst.FindAll(ast => ast is CommandAst, searchNestedScriptBlocks: true);

            foreach (CommandAst functionCall in functionCalls)
            {
                string functionName = functionCall.GetCommandName();
                if (!string.IsNullOrEmpty(functionName))
                {
                    if (!functionCallCounts.ContainsKey(functionName))
                    {
                        functionCallCounts[functionName] = 1;
                    }
                    else
                    {
                        functionCallCounts[functionName]++;
                    }
                }
            }

            foreach (var item in functionCallCounts)
            {
                if (item.Value > 1)
                {
                    WriteObject($"Detected repeated calls to function '{item.Key}'. Consider optimizing by reusing results or refactoring in script: {path}");
                }
            }
        }


        private string RefactorScriptContent(string scriptContent)
        {
            // Example refactoring method for simple replacements, use AST for more complex scenarios
            scriptContent = Regex.Replace(scriptContent, @"\bWrite-Host\b", "[System.Console]::WriteLine");
            scriptContent = Regex.Replace(scriptContent, @"(\$[a-zA-Z0-9_]+) \+= ('.*')", @"$1 = $1 + $2");
            // Add more refactoring rules here

            return scriptContent;
        }
    }
}
