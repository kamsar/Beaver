$SitecoreLicensePath = Resolve-Path ..\Dependencies\Licenses\Sitecore\license-cm.xml -ErrorAction SilentlyContinue
$SitecoreDataFolder = "You need to set the $SitecoreDataFolder variable in your environment's props.ps1 file"
$SitecoreContentDatabase = "web"

# Set Cache Sizes per the Caching Guide (for CM instances; these are overridden by the CD archetype)
# NOTE: if you're using more than just master and web you'll need to modify the cache size code to fit
$MasterPrefetchCacheSize = "100MB"
$WebPrefetchCacheSize = "100MB"

$MasterDataCacheSize = "100MB"
$WebDataCacheSize = "100MB"

$MasterItemsCacheSize = "75MB"
$WebItemsCacheSize = "50MB"