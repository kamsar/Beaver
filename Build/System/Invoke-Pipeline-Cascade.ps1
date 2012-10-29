. .\System\Invoke-Pipeline.ps1

# Invokes a "Cascade" of pipelines. All pipelines contained in $pipelinePath are executed in order
# Then, after each root pipeline exists, all pipelines of the same name in any of the cascade paths are also executed (eg 'extending' the base pipeline)
# Finally, any pipelines in the cascade paths that are NOT present in $pipelinePath are executed (eg 'custom' pipelines)
function Invoke-Pipeline-Cascade([string]$pipelinePath, [string[]]$cascadePaths) {
    # get all pipelines in primary
    $pipelines = Get-ChildItem $pipelinePath -Directory

    # execute pipelines in order, and if pipeline exists in any cascades execute that immediately afterwards
    foreach($pipeline in $pipelines) {
        Invoke-Pipeline $pipeline.FullName

        foreach($cascade in $cascadePaths) {
            $cascadePath = Join-Path $cascade $pipeline.Name
            if(Test-Path $cascadePath) {
                Invoke-Pipeline $cascadePath
            }
        }
    }

    # now we execute any custom pipelines in the cascades that are NOT defined in the primary
    foreach($cascade in $cascadePaths)
    {
        $cascadePipelines = Get-ChildItem $cascade -Directory
        foreach($cascadePipeline in $cascadePipelines) {
            $primaryPath = Join-Path $pipelinePath $cascadePipeline.Name

            if(!(Test-Path $primaryPath)) {
               Invoke-Pipeline $cascadePipeline.FullName
            }
        }
    }
}