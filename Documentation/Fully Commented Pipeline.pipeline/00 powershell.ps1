# This is a PowerShell-based buildlet. You can use any PowerShell syntax you wish here.
# All variables declared in the archetype, environment, and global build properties are in scope here.
# For example, $WebWorkingDirectory is the absolute path to the "Website" folder in the deploy directory.

# For the sake of example, let's show all variables currently in scope.
Get-Variable

# To log warnings and errors that will be globally tracked (unlike Write-Warning or Write-Error)
# Use Log-Warning and Log-Error:
Log-Warning "Oops, a warning occurred"

# Log-Error supports an -Abort switch that will immediately stop script execution. If it is not specified,
# the build will continue to run and the error will be reported at the end
Log-Error "Oh darn, an error" -Abort