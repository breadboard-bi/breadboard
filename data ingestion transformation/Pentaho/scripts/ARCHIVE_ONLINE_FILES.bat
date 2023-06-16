REM ###################################################################################################################################
REM # Copyright © 2007 Breadboard BI, LLC.  All rights reserved. 								      #
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

IF EXIST D:\kettle\source_files\google\report-csv.zip move D:\kettle\source_files\google\report-csv.zip D:\kettle\source_files\archive\google\report-csv_%Date%.ZIP

IF EXIST D:\kettle\source_files\msn\Keyword_performance___Breadboard_BI___9_09_2008.zip move D:\kettle\source_files\msn\Keyword_performance___Breadboard_BI___9_09_2008.zip D:\kettle\source_files\archive\msn\msn_keyword_performance_bbbi_%Date%.ZIP

IF EXIST D:\kettle\source_files\yahoo_sm\*.zip move D:\kettle\source_files\yahoo_sm\*.zip D:\kettle\source_files\archive\yahoo_sm\
IF EXIST D:\kettle\source_files\yahoo_sm\*.csv del D:\kettle\source_files\yahoo_sm\*.csv