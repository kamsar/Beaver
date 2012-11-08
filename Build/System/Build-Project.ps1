function Build-Project([string]$projectPath, [string]$configuration, [string[]]$targets, [Collections.Generic.Dictionary[string,string]]$properties, [string]$toolsVersion) {
    
    if(!(Test-Path $projectPath)) { 
        Write-Error "Couldn't resolve build file $($projectPath)." -ErrorAction Stop
    }

    $projectPath = (Resolve-Path $projectPath).Path

    if([string]::IsNullOrEmpty($toolsVersion)) {
        $toolsVersion = "4.0"
    }

    Add-Type -AssemblyName Microsoft.Build

    if($properties -eq $null) {
        $properties = New-Object "System.Collections.Generic.Dictionary[string,string]"
    }

    if(!$properties.ContainsKey("Configuration") -and ![string]::IsNullOrEmpty($configuration)) {
        $properties.Add("Configuration", $configuration)
    }

    if($targets -eq $null) {
        [xml]$projectFile = Get-Content $projectPath
        $targetString = $projectFile.Project.GetAttribute("DefaultTargets")
        $targets = $targetString.Split(';');
    }

    . '.\System\MSBuildLogger.ps1'

    $buildLog = New-Object "PS.Build.CollectionLogger"

    $buildRequest = New-Object "Microsoft.Build.Execution.BuildRequestData"($projectPath, $buildProps, $toolsVersion, $targets, $null)

    $projectCollection = New-Object "Microsoft.Build.Evaluation.ProjectCollection"($buildProps)
    $projectCollection.RegisterLogger($buildLog)

    $buildParameters = New-Object "Microsoft.Build.Execution.BuildParameters"($projectCollection)
    $buildParameters.Loggers = $projectCollection.Loggers

    $result = [Microsoft.Build.Execution.BuildManager]::DefaultBuildManager.Build($buildParameters, $buildRequest)

    $buildLog.Messages | foreach {
        if($_.TrimStart().StartsWith("WARNING")) {
            Log-Warning $_.Replace("WARNING: ", [string]::Empty)
        }
        elseif($_.TrimStart().StartsWith("ERROR")) {
            Log-Error $_
        }
        else { 
            Write-Host $_ 
        }
    }

    if($result.OverallResult -ne "Success") {
        Log-Error "Build failed, aborting" -Abort
    }
}