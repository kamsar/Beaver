function PSScriptRoot { $MyInvocation.ScriptName | Split-Path }

$variables = Get-Variable | Where-Object { 
    [Text.RegularExpressions.Regex]::IsMatch($_.Name, '[A-Za-z0-9]+') `
    -and $_.Name -ne "StackTrace" `
    -and $_.Name -ne "args" `
    -and $_.Name -ne "false" `
    -and $_.Name -ne "true" `
    -and $_.Name -ne "input" `
    -and $_.Value -ne $null `
    -and ![string]::IsNullOrEmpty($_.Value.ToString())
}

$buildProps = New-Object "System.Collections.Generic.Dictionary[string,string]"

foreach($var in $variables){
   $buildProps.Add($var.Name, $var.Value)
}

Import-Module $(PSScriptRoot)\..\Update-Build.psm1

Update-Build $pipelineItemPath $MSBuildConfiguration $null $buildProps