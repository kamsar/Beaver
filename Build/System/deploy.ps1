#requires -version 3.0

param
(
    [string]$DeployEnvironment
)

$ErrorActionPreference = "Stop"

function PSScriptRoot { $MyInvocation.ScriptName | Split-Path }

#Set-StrictMode -Version Latest

function Get-DeployEnvironment() {
    $environmentPath = "$(PSScriptRoot)\..\Environments"

    Write-Host "Environment to deploy was not specified. Valid environments are:" -ForegroundColor Yellow

    Get-ChildItem $environmentPath -Directory | foreach {
        Write-Host $_.Name
    }

    $environment = Read-Host "Specify the environment"
    
    $candidatePath = "$($environmentPath)\$($environment)"

    if(!(Test-Path $candidatePath)) {
        Write-Host "Environment selected was not valid." -ForegroundColor Red
        return Get-DeployEnvironment
    }
    else {
        return $environment
    }
}

if([string]::IsNullOrWhiteSpace($DeployEnvironment)) {
    $DeployEnvironment = Get-DeployEnvironment
}

# Start up logging
. "$(PSScriptRoot)\ScriptLogger.ps1"

Start-Transcript -Path "$(PSScriptRoot)\..\build.log"

# Load global properties files in order
Get-ChildItem -Path "$(PSScriptRoot)\Properties" -Filter *.ps1 | foreach {
    Write-Host "Loading global properties file $($_.FullName)" -ForegroundColor DarkGreen
    . $_.FullName
}

. "$(PSScriptRoot)\Pipelines.ps1"

# Get all the cascade pipeline directories (e.g. all archetypes' pipelines and the environment's pipeline)
$CascadePipelineDirectories = @()
$ArchetypeDirectories | foreach {
    $CascadePipelineDirectories += Join-Path $_ "Pipelines"
}

$CascadePipelineDirectories += Join-Path $EnvironmentDirectory "Pipelines"

# Make magic occur - invoke all global pipelines, followed by any cascading extensions and cascading custom pipelines
Invoke-Pipeline-Cascade "$(PSScriptRoot)\..\Global" $CascadePipelineDirectories

Write-Warning-Summary
Write-Error-Summary

Stop-Transcript

Write-Host "All done!" -ForegroundColor Magenta