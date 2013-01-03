$targetFile = [string]::Concat($SourceDirectory, "\*.sln")

if(!(Test-Path $targetFile)) { 
    Log-Error "Couldn't resolve solution file $($targetFile)." -Abort
}

$buildProps = New-Object "System.Collections.Generic.Dictionary[string,string]"

Import-Module $PSScriptRoot\..\..\System\Build-Project.psm1

Build-Project $targetFile $MSBuildConfiguration @("Build") $buildProps