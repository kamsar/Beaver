function PSScriptRoot { $MyInvocation.ScriptName | Split-Path }

. "$(PSScriptRoot)\..\Pipelines.ps1"

Invoke-Pipeline $pipelineItemPath