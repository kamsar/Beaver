
$targetFile = [string]::Concat($SourceDirectory, "\*.sln")


if(!(Test-Path $targetFile)) { 
    Write-Error "Couldn't resolve solution file $($targetFile)." -ErrorAction Stop
}

$targetFile

$buildProps = New-Object "System.Collections.Generic.Dictionary[string,string]"

. '.\System\Build-Project.ps1'

Build-Project $targetFile $MSBuildConfiguration @("Build") $buildProps