$ErrorActionPreference = "Stop"

Add-Type -Path "$(PSScriptRoot)\..\Support\Beaver\bin\Beaver.dll"

function Get-Specs($transformFilePath, $rootPaths)
{
	$specs = @()

	foreach($path in $rootPaths)
	{
		$joined = Join-Path $WorkingDirectory $path -Resolve -ErrorAction SilentlyContinue
		
		# check if path resolution failed and throw an error or warning as appropriate
		if($? -eq $false) {
			if([string]::IsNullOrEmpty($errorIfTargetIsMissing) -or $errorIfTargetIsMissing -eq "true") {
				Log-Error "$($transformFilePath): TargetFile spec $($pathSpec) did not exist, aborting. If this should not cause an abort, you can add <deploy:MissingFileError>false</deploy:MissingFileError> to your transform file." -Abort
			} else {
				Log-Warning "$($transformFilePath): TargetFile spec $($pathSpec) to transform did not exist, skipping the spec";
			}
		}
		
		$specs += $joined
	}
	
	return $specs
}

function Get-Transform-Args
{
    $validVars = New-Object "System.Collections.Generic.Dictionary[String,String]"

    $allVariables = Get-Variable | foreach {
        $varName = $_.Name
        $varValue = $_.Value
        if([Text.RegularExpressions.Regex]::IsMatch($varName, '[A-Za-z0-9]+') `
        -and $varName -ne "StackTrace" `
        -and $varName -ne "args" `
        -and $varName -ne "false" `
        -and $varName -ne "true" `
        -and $varName -ne "input" `
        -and $varName -ne $null `
        -and $varValue -ne $null) {
            $validVars.Add($varName, $varValue.ToString())
        }
    }

    return $validVars
}

function Transform-Xml($transformFilePath)
{
	[xml]$transformFile = Get-Content $transformFilePath

	$ns = @{ "deploy" = "http://github.com/kamsar/xdt-deploy" }

	# resolve values for special deploy extensions to XDT language
	$rootPaths = Select-Xml -Xml $transformFile -Namespace $ns -XPath "//deploy:TargetFile" | Select -ExpandProperty Node | Select -ExpandProperty InnerText
	$errorIfTargetIsMissing = Select-Xml -Xml $transformFile -Namespace $ns -XPath "//deploy:MissingFileError" | Select -ExpandProperty Node | Select -ExpandProperty InnerText
	$condition = Select-Xml -Xml $transformFile -Namespace $ns -XPath "//deploy:Condition" | Select -ExpandProperty Node | Select -ExpandProperty InnerText

	if([string]::IsNullOrEmpty($rootPaths)) {
		Log-Warning @"
Unable to find a target file definition in $($transformFilePath).
Make sure you have a deploy:TargetFile element in it with the correct namespace (http://github.com/kamsar/xdt-deploy), eg.
<configuration xmlns:xdt="http://schemas.microsoft.com/XML-Document-Transform" xmlns:deploy="http://github.com/kamsar/xdt-deploy">
	<deploy:TargetFile>Website\Web.config</deploy:TargetFile>
</configuration>
"@
		Log-Error "Aborting." -Abort
	}

	# if we had a conditional execution specified and the condition returns false, we skip
	if($condition -ne $null -and !(Invoke-Expression $condition)) {
		Write-Host "$($transformFilePath) transform condition was false - skipping transform."
		Write-Host "Condition that failed was: $($condition)"
	}
	else {
		# because rootPaths can be specified in multiple elements (targeting the transform at several path specs which may have wildcards each), we must iterate over it and resolve full paths
		$specs = Get-Specs $transformFilePath $rootPaths
		
		if($specs -eq $null) {
			return;
		}
		
		$transformArgs = Get-Transform-Args
		
		Write-Host "Transforming $([string]::Join(", ", $specs)) using transform file $transformFilePath"
        $results = [Beaver.ConfigTransformation.InPlaceTransformer]::Transform($transformFilePath, $transformArgs, $specs)

        $results.Messages | Write-Host

        if(-not $results.Success) {
            Log-Error "Errors occurred during transformation" -Abort
            exit 1
        }
	}
}

Transform-Xml $pipelineItemPath