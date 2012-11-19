# Delete the webDAV config file
$davConfig = "$($WebWorkingDirectory)\App_Config\Include\Sitecore.WebDAV.config"
	
if(Test-Path $davConfig) {
    Remove-Item $davConfig -Force
}