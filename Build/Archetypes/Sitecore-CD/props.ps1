$SitecoreLicensePath = Resolve-Path ..\Dependencies\Licenses\Sitecore\license-cd.xml -ErrorAction SilentlyContinue
$RemoveMasterDatabase = $true
$SitecoreContentDatabase = "web"

# Set Cache Sizes per the Caching Guide (for CD instances)
# NOTE: if you're using more than just master and web you'll need to modify the cache size code to fit
# NOTE: master settings are commented out as CD normally won't have a master database

# $MasterPrefetchCacheSize = "150MB"
$WebPrefetchCacheSize = "150MB"

# $MasterDataCacheSize = "125MB"
$WebDataCacheSize = "125MB"

# $MasterItemsCacheSize = "125MB"
$WebItemsCacheSize = "125MB"