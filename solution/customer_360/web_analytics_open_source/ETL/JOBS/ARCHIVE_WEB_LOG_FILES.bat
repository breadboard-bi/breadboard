REM ###################################################################################################################################
REM # Copyright © 2006 Breadboard BI.  All rights reserved. 									      #
REM #                                                                                                                                 #
REM # This component is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License     #
REM # as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.           #
REM #                                                                                                                                 #
REM # It is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of            #
REM # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.                      #
REM #                                                                                                                                 #
REM # You should have received a copy of the GNU General Public License along with this data mart; if not, write to the Free Software #
REM # Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA                                                      #
REM ###################################################################################################################################

REM This batch file moves the current log file into an archive folder and tags the file name with the date.  Update the path for your server.

for /f "tokens=2-4 delims=/ " %%a in ('DATE /T') do set date=%%c-%%b-%%a

IF EXIST C:\Kettle-2.3.0B\source_files\access.log copy C:\Kettle-2.3.0B\source_files\access.log C:\Kettle-2.3.0B\source_files\archive\access.log_%Date%.log

EXIT