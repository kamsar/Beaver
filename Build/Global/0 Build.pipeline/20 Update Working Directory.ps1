# Updates the working directory with the most current codebase using ROBOCOPY. If an existing codebase has already been deployed here, ROBOCOPY will attempt to mirror the
# existing code with the current build (changed local files will be overwritten, same files will be ignored) for speed.
robocopy $SourceWebDirectory $WebWorkingDirectory /XA:HS /MIR /NDL /XD .git .svn aspnet_client /XF *.ai *.psd *.fla Thumbs.db /NP

if($LASTEXITCODE -gt 7) {
    Log-Error "Robocopy threw an error. Aborting." -Abort
}