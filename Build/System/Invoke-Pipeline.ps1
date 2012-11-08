function Invoke-Pipeline([string]$path)
{
    Test-Path $path -ErrorAction Stop > $null

    $pipelineName = [IO.Path]::GetFileName($path)
    $pipelinePath = $path.TrimEnd('\', '/')

    Write-Host "Pipeline $($pipelinePath) executing." -ForegroundColor Green

    Get-ChildItem  "$($pipelinePath)\*" | Sort -Property $_.Name | foreach { 
        Write-Host "Executing pipeline item $($_.Name)" -ForegroundColor Cyan
    
        $providerPath = ".\System\Pipeline Providers\$($_.Extension.TrimStart('.')).ps1"

        if(!(Test-Path $providerPath)) {
            Log-Warning "Pipeline Provider not found for $($_.FullName)! Skipping item. Expected provider path was $($providerPath)"
            return
        }

        $pipelineItemPath = $_.FullName

        & $providerPath
    }

    Write-Host "Pipeline $($pipelinePath) complete." -ForegroundColor Green
}