#!/usr/bin/php -q 
<?php 

    // This will read a Squid cache object (read: cache file) and put the information it 
    // finds into public properties of our class so that we can carry out useful admin 
    // tasks, like getting the URL from a cache file so we can PURGE it from the Squid 
    // cache. This example script was written to be used via the command line. 

    // Written by Warren Smith 

    // Include the SquidCacheObject class 
    include_once('../SquidCacheObject.class.inc.php'); 

    // Instantiate the SquidCacheObject object, providing the Squid cache file as an argument 
    $CacheObject = new SquidCacheObject('./00000061'); 

    // This will dump the contents of the SquidCacheObject 
    var_dump($CacheObject); 

?> 
