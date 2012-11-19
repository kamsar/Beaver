# Cleans the Sitecore filesystem by removing files that are not required for any build
$itemsToRemove = @(`
	"$($WebWorkingDirectory)\indexes", `
	"$($WebWorkingDirectory)\data",	`
	"$($WebWorkingDirectory)\MediaCache\*", `
	"$($WebWorkingDirectory)\App_Data\MediaCache\*", `
	"$($WebWorkingDirectory)\temp\*", `
	"$($WebWorkingDirectory)\upload\*", `
	"$($WebWorkingDirectory)\App_Config\ConnectionStringsOracle.config", `
	"$($WebWorkingDirectory)\web.config.Oracle", `
	"$($WebWorkingDirectory)\App_Config\Include\*.example", `
	"$($WebWorkingDirectory)\sitecore\admin\packages\*")

$itemsToRemove | foreach {
    if(Test-Path $_) {
        Remove-Item $_ -Force -Recurse
    }
    else {
        Write-Host "Note path to remove $($_) did not exist - skipping it"
    }
}

$tempPath = "$($WebWorkingDirectory)\temp\*"
if(Test-Path $tempPath) {
    Remove-Item  $tempPath -Force -Recurse -Exclude readme.txt
} else {
    Write-Host "Note path to remove $($tempPath) did not exist - skipping it"
}

$uploadPath = "$($WebWorkingDirectory)\upload\*"
if(Test-Path $uploadPath) {
    Remove-Item  -Force -Recurse -Exclude readme.txt
} else {
    Write-Host "Note path to remove $($uploadPath) did not exist - skipping it"
}