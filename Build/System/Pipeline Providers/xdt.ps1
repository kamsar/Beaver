function Transform-Xml($transformationPath, $fileToTransform)
{
    $tempSourceName = "xdt-source-temp.xml"
    $rootPathDirectory = [IO.Path]::GetDirectoryName($fileToTransform)
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

    Write-Host "Transforming " $fileToTransform " using transform file " $transformationPath

    Rename-Item $fileToTransform $tempSourceName

    if($? -eq $false) {
        Log-Error "Unable to create temp file for processing transform. Aborting." -Abort
    }

    $transformProcess = Start-Process -FilePath ".\System\Pipeline Providers\Support\ctt.exe" -ArgumentList ("s:`"$($tempSourcePath)`"", "t:`"$($transformationPath)`"", "d:`"$($fileToTransform)`"", "p:$($variablesArgs)") -NoNewWindow -Wait -PassThru

    Remove-Item $tempSourcePath

    if($transformProcess.ExitCode -ne 0) {
        Log-Error "A problem occurred applying XDT transformation. Aborting." -Abort
    }
}

[xml]$transformFile = Get-Content $pipelineItemPath

$ns = @{ "deploy" = "http://github.com/kamsar/xdt-deploy" }

# resolve values for special deploy extensions to XDT language
$rootPaths = Select-Xml -Xml $transformFile -Namespace $ns -XPath "//deploy:TargetFile" | Select -ExpandProperty Node | Select -ExpandProperty InnerText
$errorIfTargetIsMissing = Select-Xml -Xml $transformFile -Namespace $ns -XPath "//deploy:MissingFileError" | Select -ExpandProperty Node | Select -ExpandProperty InnerText
$condition = Select-Xml -Xml $transformFile -Namespace $ns -XPath "//deploy:Condition" | Select -ExpandProperty Node | Select -ExpandProperty InnerText

if([string]::IsNullOrEmpty($rootPaths)) {
    Log-Warning @"
Unable to find a target file definition in $($pipelineItemPath).
Make sure you have a deploy:TargetFile element in it with the correct namespace (http://github.com/kamsar/xdt-deploy), eg.
<configuration xmlns:xdt="http://schemas.microsoft.com/XML-Document-Transform" xmlns:deploy="http://github.com/kamsar/xdt-deploy">
	<deploy:TargetFile>Website\Web.config</deploy:TargetFile>
</configuration>
"@
    Log-Error "Aborting." -Abort
}

# if we had a conditional execution specified and the condition returns false, we skip
if($condition -ne $null -and !(Invoke-Expression $condition)) {
    Write-Host "$($pipelineItemPath) transform condition was false - skipping transform."
    Write-Host "Condition that failed was: $($condition)"
}
else {
    # because rootPaths can be specified in multiple elements (targeting the transform at several path specs which may have wildcards each), we must iterate over it
    foreach($pathSpec in $rootPaths) {
        # create the absolute path(s) of the file(s) referred to by the spec (e.g. "c:\web.config" or "c:\*.config")
        $fileSpecs = Join-Path $WorkingDirectory $pathSpec -Resolve -ErrorAction SilentlyContinue

        # check if path resolution failed and throw an error or warning as appropriate
        if($? -eq $false) {
            if([string]::IsNullOrEmpty($errorIfTargetIsMissing) -or $errorIfTargetIsMissing -eq "true") {
                Log-Error "$($pipelineItemPath): TargetFile spec $($pathSpec) did not exist, aborting. If this should not cause an abort, you can add <deploy:MissingFileError>false</deploy:MissingFileError> to your transform file." -Abort
            } else {
                Log-Warning "$($pipelineItemPath): TargetFile spec $($pathSpec) to transform did not exist, skipping the spec";
            }
        }
        else {
            # execute the XDT transformation on each file matching the path spec in turn
            foreach($spec in $fileSpecs) {
                Transform-Xml $pipelineItemPath $spec
            }
        }
    }
}

