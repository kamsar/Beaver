# Sets default pipeline properties used for all pipelines

if($DeployEnvironment -eq $null) {
    Write-Error "DeployEnvironment variable was not defined. It is required." -ErrorAction Stop
}

Write-Host "Using environment $($DeployEnvironment)"

$EnvironmentDirectory = Resolve-Path ".\Environments\$($DeployEnvironment)" -ErrorAction Stop

############## LOADING ENVIRONMENT AND ARCHETYPE PROPERTIES FILES ###########################

# If we have an environmental properties file we want to load that to get the archetypes it defines if any
$EnvironmentPropertiesPath = Join-Path $EnvironmentDirectory "props.ps1"
if(Test-Path $EnvironmentPropertiesPath) {
    . $EnvironmentPropertiesPath
    Write-Host "Loaded $($EnvironmentPropertiesPath)"
}
else {
    Write-Warning "$($DeployEnvironment) did not contain a props.ps1 file. This should usually exist."
}

# make sure archetypes array exists if not defined
if($DeployArchetypes -eq $null) {
    $DeployArchetypes = @()
}

# Resolve paths to archetypes
$ArchetypeDirectories = @()
$DeployArchetypes | foreach {
    $ArchetypeDirectories += Resolve-Path ".\Archetypes\$($_)" -ErrorAction Stop
    Write-Host "Using archetype $($_)"
}

# If we have a valid set of archetypes (from the environment props) we want to load archetype properties files
$ArchetypeDirectories | foreach { 
    $ArchetypePropsPath = Join-Path $_ "props.ps1"
    if(Test-Path $ArchetypePropsPath) {
        . $ArchetypePropsPath
        Write-Host "Loaded $($ArchetypePropsPath)"
    }
    else {
        Write-Host "Archetype $($_) did not have a props.ps1 file."
    }
}

# Now that we've loaded archetype props, we want to *reload* the environment props - this will cause it to override values in the archetypes
if(Test-Path $EnvironmentPropertiesPath) {
    . $EnvironmentPropertiesPath
}
############## END LOADING ENVIRONMENT AND ARCHETYPE PROPERTIES FILES ########################

if($SourceDirectory -eq $null){
    $SourceDirectory = Resolve-Path '..' -ErrorAction Stop
}

if($WorkingDirectory -eq $null) {
    $WorkingDirectory = Resolve-Path "..\Deploy" -ErrorAction Stop

    New-Item -Type Directory -Path $WorkingDirectory -Name $DeployEnvironment -ErrorAction SilentlyContinue

    $WorkingDirectory = Join-Path $WorkingDirectory $DeployEnvironment
}



if($MSBuildConfiguration -eq $null) {
    $MSBuildConfiguration = "Debug"
}

if($SourceWebDirectory -eq $null) {
    $SourceWebDirectory = Resolve-Path "$($SourceDirectory)\Source\*.Web" -ErrorAction Stop
}

if($WebWorkingDirectory -eq $null) {
    $WebWorkingDirectory = Join-Path $WorkingDirectory "Website"
}





