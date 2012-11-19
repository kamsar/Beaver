$SourceDataDirectory = Join-Path $SourceWebDirectory "Data"
$DataWorkingDirectory = Join-Path $WorkingDirectory "Data"

New-Item -ItemType Directory -Path $DataWorkingDirectory -ErrorAction SilentlyContinue
if(![string]::IsNullOrEmpty($SitecoreLicensePath)) {
	Copy-Item $SitecoreLicensePath "$($DataWorkingDirectory)\license.xml"
}
Copy-Item "$($SourceDataDirectory)\webdav.lic" "$($DataWorkingDirectory)\webdav.lic"
New-Item -ItemType Directory -Path "$($DataWorkingDirectory)\packages" -ErrorAction SilentlyContinue