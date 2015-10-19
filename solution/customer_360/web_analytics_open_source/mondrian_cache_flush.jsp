<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0//EN" "http://www.w3.org/TR/REC-html40/strict.dtd"> 

<!-- Provided courtesy Breadboard BI, LLC - www.breadboardbi.com -->

<html> 
<head> 
<title>Breadboard BI, LLC - Flush Mondrian Cache</title> 
</head> 
<body> 

<!-- This is a simple jsp page which calls the cache-flushing code.  A Kettle HTTP job entry in a job and link it to the last transformation in the job. -->

<% mondrian.rolap.cache.CachePool.instance().flush(); %> 
 
</body> 
</html>