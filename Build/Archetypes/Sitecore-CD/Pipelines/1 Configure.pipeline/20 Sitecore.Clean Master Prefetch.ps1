# Removes the prefetch config for the master database if we're removing the master db from a CD instance

$prefetchPath = "$($WebWorkingDirectory)\App_Config\Prefetch\Master.config"

if($RemoveMasterDatabase -eq $true -and (Test-Path $prefetchPath)) {
	Remove-Item $prefetchPath -Force
}