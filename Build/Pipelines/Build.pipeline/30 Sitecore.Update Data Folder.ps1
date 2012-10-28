# TODO: these two vars need to come from external sources
$SitecoreLicensePath = Resolve-Path ..\Dependencies\Licenses\license.xml
$SitecoreDataFolder = "C:\fake\path"

$SourceDataDirectory = Join-Path $SourceWebDirectory "Data"

New-Item -ItemType Directory -Path $DataWorkingDirectory -ErrorAction SilentlyContinue
Copy-Item $SitecoreLicensePath "$($DataWorkingDirectory)\license.xml"
Copy-Item "$($SourceDataDirectory)\webdav.lic" "$($DataWorkingDirectory)\webdav.lic"
New-Item -ItemType Directory -Path "$($DataWorkingDirectory)\packages" -ErrorAction SilentlyContinue

#TODO: set data folder here in WebWorkingDirectory web.config