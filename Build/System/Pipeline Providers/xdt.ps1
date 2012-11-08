[xml]$transformFile = Get-Content $pipelineItemPath

$ns = @{ "deploy" = "http://github.com/kamsar/xdt-deploy" }

$rootPath = Select-Xml -Xml $transformFile -Namespace $ns -XPath "/configuration/deploy:TargetFile" | Select -ExpandProperty Node | Select -ExpandProperty InnerText

if([string]::IsNullOrEmpty($rootPath)) {
    Log-Warning @"
Unable to find a target file definition in $($pipelineItemPath).
Make sure you have a deploy:TargetFile element in it with the correct namespace (http://github.com/kamsar/xdt-deploy), eg.
<configuration xmlns:xdt="http://schemas.microsoft.com/XML-Document-Transform" xmlns:deploy="http://github.com/kamsar/xdt-deploy">
	<deploy:TargetFile>Website\Web.config</deploy:TargetFile>
</configuration>
"@
    Log-Error "Aborting." -Abort
}

$rootPath = Join-Path $WorkingDirectory $rootPath | Resolve-Path

if($? -eq $false) {
    Log-Error "Path to transform did not exist, aborting." -Abort
}

$tempSourceName = "xdt-source-temp.xml"
$rootPathDirectory = [IO.Path]::GetDirectoryName($rootPath)
$tempSourcePath = Join-Path $rootPathDirectory $tempSourceName

# Compose variables in current scope into parameter format to pass to ctt.exe
# See http://outcoldman.com/en/blog/show/238
$variables = @() 

Get-Variable | Where-Object { 
    [Text.RegularExpressions.Regex]::IsMatch($_.Name, '[A-Za-z0-9]+') `
    -and $_.Name -ne "StackTrace" `
    -and $_.Name -ne "args" `
    -and $_.Name -ne "false" `
    -and $_.Name -ne "true" `
    -and $_.Name -ne "input" `
    -and $_.Value -ne $null `
    -and ![string]::IsNullOrEmpty($_.Value.ToString())
} | foreach {
    $variables += "$($_.Name):`"$($_.Value)`""
}

$variablesArgs = [string]::Join(";", $variables)

Write-Host "Transforming " $rootPath.Path " using transform file " $pipelineItemPath

Rename-Item $rootPath $tempSourceName

if($? -eq $false) {
    Log-Error "Unable to create temp file for processing transform. Aborting." -Abort
}

$transformProcess = Start-Process -FilePath ".\System\Pipeline Providers\Support\ctt.exe" -ArgumentList ("s:`"$($tempSourcePath)`"", "t:`"$($pipelineItemPath)`"", "d:`"$($rootPath)`"", "p:$($variablesArgs)") -NoNewWindow -Wait -PassThru

Remove-Item $tempSourcePath

if($transformProcess.ExitCode -ne 0) {
    Log-Error "A problem occurred applying XDT transformation. Aborting." -Abort
}

