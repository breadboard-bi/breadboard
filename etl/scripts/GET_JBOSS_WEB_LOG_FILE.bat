REM ###################################################################################################################################
REM # Copyright © 2007 Breadboard BI, LLC.  All rights reserved. 									      							  #
REM #                                                                                                                                 #
REM ###################################################################################################################################

@ECHO

REM C:\pentaho\jboss\server\default\log\localhost_access_log.2006-10-11.log

IF EXIST D:\kettle\source_files\bbbi\jboss.log DEL D:\kettle\source_files\bbbi\jboss.log

IF EXIST D:\pentaho\jboss\server\default\log\localhost_access* COPY D:\pentaho\jboss\server\default\log\localhost_access* D:\kettle\source_files\bbbi\jboss.log