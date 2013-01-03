$ErrorActionPreference = "Stop"

function PSScriptRoot { $MyInvocation.ScriptName | Split-Path }

Add-Type -Path "$(PSScriptRoot)\Support\Beaver\bin\Beaver.dll"

function Build-Project([string]$projectPath, [string]$configuration, [string[]]$targets, [Collections.Generic.Dictionary[string,string]]$properties, [string]$toolsVersion) {
    
    if(!(Test-Path $projectPath)) { 
        Write-Error "Couldn't resolve build file $($projectPath)." -ErrorAction Stop
    }

    $projectPath = (Resolve-Path $projectPath).Path
exit 1
    $result = [Beaver.Build]::BuildHelper.BuildProject($projectPath, $configuration, $targets, $properties, $toolsVersion)

    $result.Messages | foreach {
        if($_.TrimStart().StartsWith("WARNING")) {
            Log-Warning $_.Replace("WARNING: ", [string]::Empty)
        }
        elseif($_.TrimStart().StartsWith("ERROR")) {
            Write-Host $_ -ForegroundColor Red            et
        }
        else { 
            Write-Host $_ 
        }
    }

    if(-not $result.Success) {
        Write-Error "Build failed, aborting"
        Exit 1
    }
}

Export-ModuleMember -Function Build-Project