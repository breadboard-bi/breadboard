REM ###################################################################################################################################
REM # Copyright © 2007 Breadboard BI, LLC.  All rights reserved. 									      							  #
REM #                                                                                                                                 #
REM ###################################################################################################################################

@echo

rem for /f "tokens=2-4 delims=/ " %%a in ('DATE /T') do set date=%%c-%%b-%%a

for /f "tokens=2-4 delims=/ " %%a in ('date /T') do set year=%%c
for /f "tokens=2-4 delims=/ " %%a in ('date /T') do set month=%%a
for /f "tokens=2-4 delims=/ " %%a in ('date /T') do set day=%%b
set date=%year%-%month%-%day%

for /f "tokens=1 delims=: " %%h in ('time /T') do set hour=%%h
for /f "tokens=2 delims=: " %%m in ('time /T') do set minutes=%%m
for /f "tokens=3 delims=: " %%a in ('time /T') do set ampm=%%a
set NOW=%hour%-%minutes%-%ampm%

IF EXIST D:\kettle\source_files\bbbi\access.log copy D:\kettle\source_files\bbbi\access.log D:\kettle\source_files\archive\yahoo\yahoo_%Date%.log

IF EXIST D:\kettle\source_files\bbbi\jboss.log copy D:\kettle\source_files\bbbi\jboss.log D:\kettle\source_files\archive\jboss\jboss_%Date%_%NOW%.log

REM Deletes Nick's Log (no need to take up space on disk).
IF EXIST D:\kettle\source_files\goodman\access.log del D:\kettle\source_files\goodman\access.log 

REM Below calculates yesterday then deletes yesterday's log file
REM Much of the following script was adopted from the Yesterday.bat script written by Rob van der Woude (http://www.robvanderwoude.com/index.html)

:: Strip leading zero from Day
SET DayS=%day%
IF %day:~0,1%==0 SET DayS=%day:~1%

:: Calculate yesterday's date
IF %DayS% EQU 1 (
	SET YesterY=%year%
	CALL :RollMonth
) ELSE (
	SET /A YesterD=%DayS% - 1
	SET YesterM=%month%
	SET YesterY=%year%
)

:: Add leading zero to YesterD if necessary
IF %YesterD% LSS 10 SET YesterD=0%YesterD%

:: Yesterday's date in YYYYMMDD format
SET yesterday=%YesterY%-%YesterM%-%YesterD%

IF EXIST D:\pentaho\jboss\server\default\log\localhost_access_log.%yesterday%.log del D:\pentaho\jboss\server\default\log\localhost_access_log.%yesterday%.log

:: Done
rem ENDLOCAL
rem GOTO:EOF


:: * * * * * * * *  Subroutines  * * * * * * * *


:: Subroutine to get yesterday's date if today is the first day of the month
:: Thanks for Aaron M. Jones who pointed out an error in the YesterD value for Month 2
:RollMonth
IF %month%==01 (
	SET YesterD=31
	SET YesterM=12
	SET /A YesterY = %Year% - 1
)
IF %month%==02 (
	SET YesterD=31
	SET YesterM=01
)
IF %month%==03 (
	SET YesterD=28
	SET YesterM=02
	CALL :LeapYear
)
IF %month%==04 (
	SET YesterD=31
	SET YesterM=03
)
IF %month%==05 (
	SET YesterD=30
	SET YesterM=04
)
IF %month%==06 (
	SET YesterD=31
	SET YesterM=05
)
IF %month%==07 (
	SET YesterD=30
	SET YesterM=06
)
IF %month%==08 (
	SET YesterD=31
	SET YesterM=07
)
IF %month%==09 (
	SET YesterD=31
	SET YesterM=08
)
IF %month%==10 (
	SET YesterD=30
	SET YesterM=09
)
IF %month%==11 (
	SET YesterD=31
	SET YesterM=10
)
IF %month%==12 (
	SET YesterD=30
	SET YesterM=11
)
GOTO:EOF


rem :End

rem EXIT