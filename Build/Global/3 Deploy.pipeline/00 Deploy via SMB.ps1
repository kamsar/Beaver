# Deploys the results of the deploy to somewhere remove via local filesystem or SMB share
# You just need to set the $RemoteDeployPath in a props file to either a single or array of paths to deploy to

if($RemoteDeployPath -and $ExecuteRemoteDeployment) {
    $RemoteDeployPath | foreach {
        Write-Host "Deploying to $_ via filesystem/SMB..."
		
		# Copy the website folder using mirror (will purge old or deleted files)
        robocopy $WebWorkingDirectory $_\Website /XA:HS /MIR /NDL /XD .git .svn aspnet_client /XF *.ai *.psd *.fla Thumbs.db /NP
		
		# Copy over any other folders alongside web simply overwriting existing (preserves out of webroot logs, indexes, etc)
		robocopy $WorkingDirectory $_ /XA:HS /E /NDL /XD .git .svn aspnet_client /XF *.ai *.psd *.fla Thumbs.db /NP
    }
}

if($LASTEXITCODE -gt 7) {
    Log-Error "Robocopy threw an error during remote deployment. Aborting." -Abort
}