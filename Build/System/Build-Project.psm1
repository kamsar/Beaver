$ErrorActionPreference = "Stop"

function PSScriptRoot { $MyInvocation.ScriptName | Split-Path }

Add-Type -Path "$(PSScriptRoot)\Support\Beaver\bin\Beaver.dll"

function Build-Project([string]$projectPath, [string]$configuration, [string[]]$targets, [Collections.Generic.Dictionary[string,string]]$properties, [string]$toolsVersion) {
    
    if(!(Test-Path $projectPath)) { 
        Write-Error "Couldn't resolve build file $($projectPath)." -ErrorAction Stop
    }

    $projectPath = (Resolve-Path $projectPath).Path

    Write-Host "Starting build of $projectPath..."

    $result = [Beaver.Build.BuildHelper]::BuildProject($projectPath, $configuration, $targets, $properties, $toolsVersion)

    $result.Messages | foreach {
        if($_.Type -eq "Error") {
            Write-Host $_.Text -ForegroundColor Red
        }
        elseif($_.Type -eq "Warning") {
            Write-Host $_.Text -ForegroundColor Yellow
        }
        else { 
            Write-Host $_.Text
        }
    }

    if(-not $result.Success) {
        Write-Error "Build failed, aborting"
        Exit 1
    }
}

Export-ModuleMember -Function Build-Project