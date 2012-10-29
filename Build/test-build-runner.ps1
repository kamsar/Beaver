$DeployEnvironment = "Dev-CM"

. .\System\Properties\default-props.ps1
. .\System\Invoke-Pipeline-Cascade.ps1

# Get all the cascade pipeline directories (e.g. all archetypes' pipelines and the environment's pipeline)
$CascadePipelineDirectories = @()
$ArchetypeDirectories | foreach {
    $CascadePipelineDirectories += Join-Path $_ "Pipelines"
}

$CascadePipelineDirectories += Join-Path $EnvironmentDirectory "Pipelines"

# Make magic occur - invoke all global pipelines, followed by any cascading extensions and cascading custom pipelines
Invoke-Pipeline-Cascade ".\Global" $CascadePipelineDirectories