. .\test-build-args.ps1
. .\System\Invoke-Pipeline.ps1



Invoke-Pipeline ".\Pipelines\Build"
Invoke-Pipeline "Pipelines\Test Pipeline"