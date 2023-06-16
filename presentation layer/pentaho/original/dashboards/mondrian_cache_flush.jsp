<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0//EN" "http://www.w3.org/TR/REC-html40/strict.dtd"> 

<!--
/*
*  Copyright 2006 BreadBoard BI, Inc..  All rights reserved. 
*
*  Version 1.1
*
*  This software was developed by Breadboard BI and is provided under license. You may 
*  not use this file except in compliance with the license. This software is distributed 
*  on an AS IS basis, WITHOUT WARRANTY OF ANY KIND, neither express nor implied.
*
*  Please send bug fixes and enhancement requests to submit@breadboardbi.com
*/
-->
 
<html> 
<head> 
<title>Breadboard BI - Flush Mondrian Cache</title> 
</head> 
<body> 

<!-- This is a simple jsp page which calls the cache-flushing code.  A Kettle HTTP job entry in a job and link it to the last transformation in the job. -->

<% mondrian.rolap.cache.CachePool.instance().flush(); %> 
 
</body> 
</html>