function Invoke-Pipeline([string]$path)
{
    Test-Path $path -ErrorAction Stop > $null

    $pipelineName = [IO.Path]::GetFileName($path)
    $pipelinePath = $path.TrimEnd('\', '/')

    Write-Output "Pipeline $($pipelineName) executing."

    Get-ChildItem  "$($pipelinePath)\*.*" | Sort -Property $_.Name | foreach { 
        "Executing $($_.Name)";
    
        $providerPath = ".\System\Pipeline Providers\$($_.Extension.TrimStart('.')).ps1"

        if(!(Test-Path $providerPath)) {
            Write-Error "Provider not found for $($_.Name)!" -ErrorAction Stop
        }

        $pipelineItemPath = $_.FullName

        & $providerPath
    }

    Write-Output "Pipeline $($pipelineName) complete."
}