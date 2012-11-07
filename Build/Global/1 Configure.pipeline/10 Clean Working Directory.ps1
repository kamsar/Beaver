# Cleans unnecessary files (project files, etc) from the deployed solution

# Project files in the root
Get-ChildItem "$($WebWorkingDirectory)\*" -Include *.csproj,*.vbproj,*.user,*.sln,*.suo,packages.config | Remove-Item -Force

# Thumbs db and Mac .DS_Store files, log files
Get-ChildItem $WebWorkingDirectory -Recurse -Include @("Thumbs.db", ".DS_Store", "*.FxCop", "*.log") | Remove-Item -Force

# Source files (.cs, .vb, .fs)
if($CleanSourceCode -eq $null -or $CleanSourceCode -eq $true) {
    Get-ChildItem $WebWorkingDirectory -Recurse -Include @("*.cs", "*.vb", "*.fs") | Remove-Item -Force
}

# Delete the obj directory
Remove-Item "$($WebWorkingDirectory)\obj" -Force -Recurse -ErrorAction SilentlyContinue