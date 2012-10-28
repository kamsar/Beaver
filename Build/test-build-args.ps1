$SourceDirectory = Resolve-Path '..' -ErrorAction Stop
$WorkingDirectory = Resolve-Path '..\Deploy\Test Root' -ErrorAction SilentlyContinue

$DeployArchetype = "CM"
$DeployEnvironment = "Dev-CM"

$MSBuildConfiguration = "Debug"

$SourceWebDirectory = Join-Path $SourceDirectory "Source\Test.Web"

$WebWorkingDirectory = Join-Path $WorkingDirectory "Website"
$DataWorkingDirectory = Join-Path $WorkingDirectory "Data"

$ArchetypeDirectory = Resolve-Path ".\Archetypes\$($DeployArchetype)" -ErrorAction SilentlyContinue
$EnvironmentDirectory = Resolve-Path ".\Environments\$($DeployEnvironment)" -ErrorAction SilentlyContinue
