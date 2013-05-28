$targetFile = [string]::Concat($SourceDirectory, "\*.sln")

if(!(Test-Path $targetFile)) { 
    Log-Error "Couldn't resolve solution file $($targetFile)." -Abort
}

$buildProps = New-Object "System.Collections.Generic.Dictionary[string,string]"

Import-Module $PSScriptRoot\..\..\System\Update-Build.psm1

Update-Build $targetFile $MSBuildConfiguration @("Rebuild") $buildProps "4.0"
