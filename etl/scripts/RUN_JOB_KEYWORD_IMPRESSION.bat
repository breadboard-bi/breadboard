REM ###################################################################################################################################
REM # Copyright © 2007 Breadboard BI, LLC.  All rights reserved. 							              #
REM ###################################################################################################################################

CD D:\kettle
kitchen.bat /rep:"kettle_bbbi" /job:"JOB_KEYWORD_IMPRESSION" /dir:/ /user:admin /pass:admin /level:Minimal  >> "D:\kettle\logs\JOB_KEYWORD_IMPRESSION.log"