# Cleans the Sitecore filesystem by removing Sitecore Rocks support files
$rocksItems = @(`
	"$($WebWorkingDirectory)\bin\Sitecore.Rocks*.dll", `
	"$($WebWorkingDirectory)\sitecore\shell\WebService\Browse.aspx",	`
	"$($WebWorkingDirectory)\sitecore\shell\WebService\Service2.asmx")
	
$rocksItems | foreach {
    if(Test-Path $_) {
        Remove-Item $_ -Force
    }
}