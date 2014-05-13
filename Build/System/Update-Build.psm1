$ErrorActionPreference = "Stop"

function PSScriptRoot { $MyInvocation.ScriptName | Split-Path }

function Update-Build([string]$projectPath, [string]$configuration, [string]$target) {
    
    if(!(Test-Path $projectPath)) { 
        Write-Error "Couldn't resolve build file $projectPath." -ErrorAction Stop
    }

    $projectPath = (Resolve-Path $projectPath).Path

    # Handle fallback of WebApplication.targets between VS2012 and VS2013 (to allow build with either installed)
    $vsVersion="12.0"
    $vsPath="C:\Program Files (x86)\MSBuild\Microsoft\VisualStudio\v"
    $vsFile="WebApplications\Microsoft.WebApplication.targets"

    if(-NOT (Test-Path "$vsPath$vsVersion\$vsFile")) {
        $vsVersion="11.0"
    }

    Write-Host "Starting build of $projectPath using Visual Studio $vsVersion..."

    $msBuild = 'c:\WINDOWS\Microsoft.NET\Framework64\v4.0.30319\msbuild.exe'
    $nuGet = Join-Path $PSScriptRoot "..\..\Dependencies\Tools\NuGet\NuGet.exe"

    & $nuGet restore $projectPath 2>&1 | out-host
    & $msBuild $projectPath /p:Configuration=$configuration /m /t:$target /p:VisualStudioVersion=$vsVersion /nr:false 2>&1 | out-host

    if($LastExitCode -ne 0) {
        Write-Error "Build failed, aborting (MSBuild.exe exited with code $LastExitCode)"
        Exit 1
    }
}

Export-ModuleMember -Function Update-Build