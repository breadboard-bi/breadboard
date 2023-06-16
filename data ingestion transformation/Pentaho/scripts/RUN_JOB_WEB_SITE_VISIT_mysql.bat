REM ###################################################################################################################################
REM # Copyright © 2007 Breadboard BI, LLC.  All rights reserved. 							              #
REM ###################################################################################################################################

CD D:\kettle
kitchen.bat /rep:"kettle_bbbi" /job:"JOB_WEB_SITE_VISIT_backup" /dir:/ /user:admin /pass:admin /level:Minimal  >> "D:\kettle\logs\JOB_WEB_SITE_VISIT.log"