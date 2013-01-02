if($DeployPath) {
    robocopy $WorkingDirectory $DeployPath /XA:HS /MIR /NDL /XD .git .svn aspnet_client /XF *.ai *.psd *.fla Thumbs.db
}

if($LASTEXITCODE -gt 7) {
    Log-Error "Robocopy threw an error. Aborting." -Abort
}