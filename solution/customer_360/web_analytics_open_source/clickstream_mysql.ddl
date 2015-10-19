/*==============================================================*/
/* DBMS name:      MYSQL Version 5                              */
/* Name:  	   Clickstream Data Mart (open source)          */
/* Version:  	   2.1         					*/
/*==============================================================*/



CREATE TABLE `ADMIN_JOB_CONTROL` (
  `ID_JOB` int(11) default NULL,
  `JOBNAME` varchar(50) default NULL,
  `STATUS` varchar(15) default NULL,
  `LINES_READ` bigint(20) default NULL,
  `LINES_WRITTEN` bigint(20) default NULL,
  `LINES_UPDATED` bigint(20) default NULL,
  `LINES_INPUT` bigint(20) default NULL,
  `LINES_OUTPUT` bigint(20) default NULL,
  `ERRORS` bigint(20) default NULL,
  `STARTDATE` datetime default NULL,
  `ENDDATE` datetime default NULL,
  `LOGDATE` datetime default NULL,
  `DEPDATE` datetime default NULL,
  `REPLAYDATE` datetime default NULL,
  `LOG_FIELD` mediumtext
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `ADMIN_TRANSFORMATION_CONTROL` (
  `ID_BATCH` int(11) default NULL,
  `TRANSNAME` varchar(50) default NULL,
  `STATUS` varchar(15) default NULL,
  `LINES_READ` bigint(20) default NULL,
  `LINES_WRITTEN` bigint(20) default NULL,
  `LINES_UPDATED` bigint(20) default NULL,
  `LINES_INPUT` bigint(20) default NULL,
  `LINES_OUTPUT` bigint(20) default NULL,
  `ERRORS` bigint(20) default NULL,
  `STARTDATE` datetime default NULL,
  `ENDDATE` datetime default NULL,
  `LOGDATE` datetime default NULL,
  `DEPDATE` datetime default NULL,
  `REPLAYDATE` datetime default NULL,
  `LOG_FIELD` mediumtext
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


CREATE TABLE `DIMENSION_SOURCE_SYSTEM` (
  `SOURCE_SYSTEM_SK` int(11) NOT NULL COMMENT 'The source system surrogate key (valued exactly the same as SOURCE_SYSTEM_ID).  This value is assigned and owned by the analytics team.',
  `SOURCE_SYSTEM_ID` int(11) default NULL COMMENT 'The source system  identifier (valued exactly the same as SOURCE_SYSTEM_SK).  This value is assigned and owned by the analytics team.',
  `SOURCE_SYSTEM_NAME` varchar(60) default NULL COMMENT 'The source system name.',
  `SOURCE_SYSTEM_DESC` varchar(255) default NULL COMMENT 'The source system  description.',
  `CONTACT_NAME` varchar(60) default NULL COMMENT 'The source system contact  person name.',
  `CONTACT_EMAIL_DESC` varchar(255) default NULL COMMENT 'The source system contact  person email address.',
  `DW_LOAD_DATE` timestamp NOT NULL default CURRENT_TIMESTAMP COMMENT 'The date the row was inserted or updated into the data warehouse table.',
  PRIMARY KEY  (`SOURCE_SYSTEM_SK`),
  UNIQUE KEY `SOURCE_SYSTEM_PK` (`SOURCE_SYSTEM_SK`),
  UNIQUE KEY `SYS_C009416` (`SOURCE_SYSTEM_SK`),
  UNIQUE KEY `DIMENSION_SOURCE_SYSTEM_AK` (`SOURCE_SYSTEM_ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='Information about the system sources (entered manually).';


CREATE TABLE `DIMENSION_DAY` (
  `DATE_SK` int(11) NOT NULL COMMENT 'The day surrogate key.  This smart key is loaded with the date value in the format YYYYMMDD.',
  `DAY_DATE` datetime default NULL COMMENT 'The date (date datatype).',
  `DAY_NAME` varchar(60) default NULL COMMENT 'The name of the day, e.g., Monday.',
  `DAY_DESC` varchar(32) default NULL COMMENT 'The date string in the format DD-MM-YYYY.',
  `MONTH_SK` int(11) default NULL COMMENT 'The month surrogate key.  Relates to the month dimension (if needed for aggregate fact tables).',
  `MONTH_NUMBER` tinyint(4) default NULL COMMENT 'The month number (1-12).',
  `MONTH_NAME` varchar(60) default NULL COMMENT 'The month name, e.g. January.',
  `QUARTER_SK` int(11) default NULL COMMENT 'The quarter surrogate key.  Relates to the quarter dimension (if needed for aggregate fact tables).',
  `QUARTER_NUMBER` tinyint(4) default NULL COMMENT 'The quarter number (1-4).',
  `QUARTER_NAME` varchar(60) default NULL COMMENT 'The quarter name, e.g., Q1.',
  `DAY_OF_WEEK_NUMBER` tinyint(4) default NULL COMMENT 'The day of the week number (1-7).',
  `DAY_OF_MONTH_NUMBER` tinyint(4) default NULL COMMENT 'The day of month number (1-31).',
  `DAYS_IN_MONTH_QTY` tinyint(4) default NULL COMMENT 'The number of days in a given month.',
  `DAY_OF_YEAR_NUMBER` smallint(6) default NULL COMMENT 'The day of year number (1-366).',
  `WEEK_OF_MONTH_NUMBER` tinyint(4) default NULL COMMENT 'The week of month number (1-5).',
  `WEEK_OF_QUARTER_NUMBER` int(11) default NULL COMMENT 'The week of quarter number.',
  `WEEK_OF_YEAR_NUMBER` int(11) default NULL COMMENT 'The week of year number (1-52).',
  `WEEKEND_IND` char(1) default NULL COMMENT 'This denotes if a day is a weekend (generally Saturday and Sunday).',
  `WEEK_OF_MONTH_NAME` varchar(60) default NULL COMMENT 'The week of month name, e.g., W1.',
  `YEAR_QUARTER_NAME` varchar(60) default NULL COMMENT 'The year quarter name, e.g., 2006Q1.',
  `WEEK_SK` int(11) default NULL COMMENT 'The calendar week surrogate key.',
  `WEEK_NAME` varchar(60) default NULL COMMENT 'The week name.  For example, 1998W45.  Note:  this assumes week starts on Sunday.',
  `WEEK_DESC` varchar(255) default NULL COMMENT 'The week description.  For example, Week of September 3, 2006.  Note:  this assumes week starts on Sunday.',
  `YEAR_SK` int(11) default '0' COMMENT 'The year surrogate key.  Relates to the year dimension (if needed for aggregate fact tables).',
  `YEAR_SORT_NUMBER` varchar(4) default NULL COMMENT 'This column is defined as a varchar datatype to allow for proper Mondrian drill-through formatting.',
  `DAY_OF_WEEK_SORT_NAME` varchar(60) default NULL COMMENT 'The day of week sort name used to overcome ordinal column issues in Mondrian.  Example format, Day 1 - Day 7.',
  `YEAR_NUMBER` smallint(6) default NULL COMMENT 'The year number.',
  `DW_VERSION_NUMBER` smallint(6) default '1' COMMENT 'The version number for the row.',
  `DW_CURRENT_IND` char(1) default 'Y' COMMENT 'The current row for a particular entity when Slowly Changing Dimension Type 2 (SCD2) functionality is used..',
  `DW_START_DATE` timestamp NOT NULL default '1971-01-01 00:00:00' COMMENT 'The start date for the row when Slowly Changing Dimension Type 2 (SCD2) functionality is used.',
  `DW_STOP_DATE` timestamp NOT NULL default '2036-12-31 00:00:00' COMMENT 'The stop date for the row when Slowly Changing Dimension Type 2 (SCD2) functionality is used.',
  `DW_LOAD_DATE` timestamp NOT NULL default CURRENT_TIMESTAMP COMMENT 'The date the row was inserted or updated into the data warehouse table.',
  PRIMARY KEY  (`DATE_SK`),
  UNIQUE KEY `DIMENSION_DAY_PK` (`DATE_SK`),
  UNIQUE KEY `DIMENSION_DAY_AK` (`DAY_DATE`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='The day (date) dimension.';


CREATE TABLE `DIMENSION_GEOGRAPHIC_LOCATION` (
  `GEO_LOCATION_SK` int(11) NOT NULL default '0' COMMENT 'The geographic location surrogate key.  This key should be loaded from a database sequence or be defined as an identity column.',
  `GEO_LOCATION_ID` double NOT NULL default '0' COMMENT 'The geographic location identifier in the source system.  Alone, or in combination with other columns (e.g., business unit, setid, source system), this value uniquely identifiers a geographic location in the source.',
  `SOURCE_SYSTEM_SK` bigint(20) default '0' COMMENT 'The source system surrogate key.  All dimensions and base grain fact tables must include this column to enable multiple source system capabililty.',
  `ISO_3166_COUNTRY_CODE` varchar(32) default '-' COMMENT 'The ISO 3166 country code.',
  `ISO_3166_COUNTRY_NAME` varchar(60) default 'Missing' COMMENT 'The ISO 3166 country name.',
  `ISO_3166_2_REGION_CODE` varchar(32) default '-' COMMENT 'The ISO 3166-2 region code.',
  `ISO_3166_2_REGION_NAME` varchar(60) default 'Missing' COMMENT 'The ISO 3166-2 region name.',
  `FIPS_10_4_REGION_CODE` varchar(32) default '-' COMMENT 'The FIPS 10-4 region code.',
  `FIPS_10_4_REGION_NAME` varchar(60) character set utf8 default 'Missing' COMMENT 'The FIPS 10-4 region name.',
  `CITY_NAME` varchar(60) character set utf8 default 'Missing' COMMENT 'The city name.',
  `POSTAL_CODE` varchar(32) default 'Missing' COMMENT 'This postal code.',
  `REGION_CODE` varchar(32) default NULL COMMENT 'The region name.  If the geographic location is the United States or Canada, this is the ISO 3166-2 region code, otherwise it is the FIPS 10-4 region code.',
  `REGION_NAME` varchar(60) character set utf8 default 'Missing' COMMENT 'The region name.  If the geographic location is the United States or Canada, this is the ISO 3166-2 region name, otherwise it is the FIPS 10-4 region name.',
  `DMA_CODE` double default '0' COMMENT 'The designated marketing area (DMA) code.',
  `DMA_NAME` varchar(255) default 'Missing' COMMENT 'The designated marketing area (DMA) name.',
  `PHONE_REGION_CODE` double default '0' COMMENT 'The telephone region code.',
  `LATITUDE_NUMBER` decimal(7,4) default NULL COMMENT 'The latitude number for the city.',
  `LONGITUDE_NUMBER` decimal(7,4) default NULL COMMENT 'The longitude number for the city.',
  `DW_VERSION_NUMBER` smallint(6) default '1' COMMENT 'The version number for the row.',
  `DW_CURRENT_IND` char(1) default 'Y' COMMENT 'The current row for a particular entity when Slowly Changing Dimension Type 2 (SCD2) functionality is used.',
  `DW_START_DATE` timestamp NOT NULL default '1971-01-01 00:00:00' COMMENT 'The start date for the row when Slowly Changing Dimension Type 2 (SCD2) functionality is used.',
  `DW_STOP_DATE` timestamp NOT NULL default '2036-12-31 00:00:00' COMMENT 'The stop date for the row when Slowly Changing Dimension Type 2 (SCD2) functionality is used.',
  `DW_LOAD_DATE` timestamp NOT NULL default CURRENT_TIMESTAMP COMMENT 'The date the row was inserted or updated into the data warehouse table.',
  PRIMARY KEY  (`GEO_LOCATION_SK`),
  UNIQUE KEY `DIMENSION_GEO_LOCATION_PK` (`GEO_LOCATION_SK`),
  KEY `DIMENSION_GEO_LOC_I` (`ISO_3166_COUNTRY_CODE`,`REGION_NAME`),
  KEY `DIMENSION_GEOGRAPHIC_LOC_AK` USING BTREE (`LATITUDE_NUMBER`,`LONGITUDE_NUMBER`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 DELAY_KEY_WRITE=1 COMMENT='The geographic location dimension.';


CREATE TABLE `DIMENSION_TIME` (
  `TIME_SK` int(11) NOT NULL COMMENT 'The time of day surrogate key.  This key should be loaded from a database sequence or be defined as an identity column.',
  `TIME_24_CODE` varchar(32) default NULL COMMENT 'The 24 hour time (e.g., 17:34).',
  `TIME_12_CODE` varchar(32) default NULL COMMENT 'The 12 hour time (e.g., 5:34).',
  `HOUR_24_CODE` varchar(32) default NULL COMMENT 'The hour (00 - 24) code for the time of day.',
  `HOUR_12_CODE` varchar(32) default NULL COMMENT 'The hour (01 - 12) code for the time of day.',
  `DW_VERSION_NUMBER` smallint(6) default '1' COMMENT 'The version number for the row.',
  `DW_CURRENT_IND` char(1) default 'Y' COMMENT 'The current row for a particular entity when Slowly Changing Dimension Type 2 (SCD2) functionality is used.',
  `DW_START_DATE` timestamp NOT NULL default '1971-01-01 00:00:00' COMMENT 'The start date for the row when Slowly Changing Dimension Type 2 (SCD2) functionality is used.',
  `DW_STOP_DATE` timestamp NOT NULL default '2036-12-31 00:00:00' COMMENT 'The stop date for the row when Slowly Changing Dimension Type 2 (SCD2) functionality is used.',
  `DW_LOAD_DATE` timestamp NOT NULL default CURRENT_TIMESTAMP COMMENT 'The date the row was inserted or updated into the data warehouse table.',
  `AM_PM_IND` varchar(2) default NULL COMMENT 'The AM/PM indicator.',
  `MINUTE_QTY` decimal(2,0) default NULL COMMENT 'The number of minutes for the time of day (0-59).',
  `HOUR_24_QTY` decimal(2,0) default NULL COMMENT 'The number of hours for the time of day (0-24).',
  `HOUR_12_QTY` decimal(2,0) default NULL COMMENT 'The number of hours for the time of day (1-12).',
  PRIMARY KEY  (`TIME_SK`),
  UNIQUE KEY `DIMENSION_TIME_PK` (`TIME_SK`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='The time of day dimension.';



CREATE TABLE `DIMENSION_WEB_BROWSER_OS` (
  `WEB_BROWSER_OS_SK` int(11) NOT NULL COMMENT 'The web browser operating system surrogate key.  This key should be loaded from a database sequence or be defined as an identity column.',
  `WEB_BROWSER_NAME` varchar(60) default 'Missing' COMMENT 'The web browser name (e.g., Firefox 1.x).',
  `WEB_BROWSER_OS_DESC` varchar(255) default 'Missing' COMMENT 'The web browser/OS description (e.g., Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.0.4) Gecko/20060508 Firefox/1.5.0.4).',
  `PARENT_WEB_BROWSER_NAME` varchar(60) default 'Missing' COMMENT 'The web browser parent name (e.g., Firefox).',
  `PARENT_OPERATING_SYSTEM_NAME` varchar(60) default 'Missing' COMMENT 'The operating system name (e.g., Windows).',
  `OPERATING_SYSTEM_NAME` varchar(60) default 'Missing' COMMENT 'The operating system name (e.g., Windows 98).',
  `DW_VERSION_NUMBER` smallint(6) default '1' COMMENT 'The version number for the row.',
  `DW_CURRENT_IND` char(1) default 'Y' COMMENT 'The current row for a particular entity when Slowly Changing Dimension Type 2 (SCD2) functionality is used.',
  `DW_START_DATE` timestamp NOT NULL default '1971-01-01 00:00:00' COMMENT 'The start date for the row when Slowly Changing Dimension Type 2 (SCD2) functionality is used.',
  `DW_STOP_DATE` timestamp NOT NULL default '2036-12-31 00:00:00' COMMENT 'The stop date for the row when Slowly Changing Dimension Type 2 (SCD2) functionality is used.',
  `DW_LOAD_DATE` timestamp NOT NULL default CURRENT_TIMESTAMP COMMENT 'The date the row was inserted or updated into the data warehouse table.',
  PRIMARY KEY  (`WEB_BROWSER_OS_SK`),
  UNIQUE KEY `DIMENSION_WEB_BROWSER_OS_PK` (`WEB_BROWSER_OS_SK`),
  KEY `DIMENSION_WEB_BROWSER_OS_AK` (`WEB_BROWSER_OS_DESC`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 DELAY_KEY_WRITE=1 COMMENT='The web browser operating system dimension.';


CREATE TABLE `DIMENSION_WEB_FILE` (
  `WEB_FILE_SK` int(11) NOT NULL COMMENT 'The web file surrogate key.  This key should be loaded from a database sequence or be defined as an identity column.',
  `WEB_FILE_NAME` varchar(2000) default 'Missing' COMMENT 'The web file name (e.g., /etl_maps.html).',
  `WEB_FILE_URL_DESC` varchar(2000) default 'Missing' COMMENT 'The web file URL description (e.g., http://www.breadboardbi.com/cubes.html).',
  `WEB_FILE_BYTE_QTY` double default NULL COMMENT 'The web file byte quantity.',
  `WEB_FILE_CAT` varchar(32) default 'Missing' COMMENT 'The web file category (e.g., html).',
  `WEB_FILE_CAT_NAME` varchar(60) default 'Missing' COMMENT 'The web file category name.  This could be used to further detail the shorter category.',
  `DW_VERSION_NUMBER` smallint(6) default '1' COMMENT 'The version number for the row.',
  `DW_CURRENT_IND` char(1) default 'Y' COMMENT 'The current row for a particular entity when Slowly Changing Dimension Type 2 (SCD2) functionality is used.',
  `DW_START_DATE` timestamp NOT NULL default '1971-01-01 00:00:00' COMMENT 'The start date for the row when Slowly Changing Dimension Type 2 (SCD2) functionality is used.',
  `DW_STOP_DATE` timestamp NOT NULL default '2036-12-31 00:00:00' COMMENT 'The stop date for the row when Slowly Changing Dimension Type 2 (SCD2) functionality is used.',
  `DW_LOAD_DATE` timestamp NOT NULL default CURRENT_TIMESTAMP COMMENT 'The date the row was inserted or updated into the data warehouse table.',
  `old_name` varchar(60) default NULL,
  PRIMARY KEY  (`WEB_FILE_SK`),
  UNIQUE KEY `DIMENSION_WEBSITE_FILE_PK` (`WEB_FILE_SK`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 DELAY_KEY_WRITE=1 COMMENT='The web file dimension.';



CREATE TABLE `DIMENSION_WEB_SITE_REFERER` (
  `REFERER_URL_SK` int(11) NOT NULL COMMENT 'The web site referer surrogate key.  This key should be loaded from a database sequence or be defined as an identity column.',
  `REFERER_URL_DESC` varchar(2000) default 'Missing' COMMENT 'The referer URL description.',
  `REFERER_DESC` varchar(255) default 'Missing' COMMENT 'The referer description.',
  `PARENT_REFERER_DESC` varchar(255) default 'Missing' COMMENT 'The parent referer description.',
  `REFERER_DOMAIN_DESC` varchar(2000) default 'Missing' COMMENT 'The referer domain from the URL.',
  `EXTERNAL_IND` varchar(1) default NULL COMMENT 'This indicates if a referer page is external to the web site.',
  `DW_VERSION_NUMBER` smallint(6) default '1' COMMENT 'The version number for the row.',
  `DW_CURRENT_IND` char(1) default 'Y' COMMENT 'The current row for a particular entity when Slowly Changing Dimension Type 2 (SCD2) functionality is used.',
  `DW_START_DATE` timestamp NOT NULL default '1971-01-01 00:00:00' COMMENT 'The start date for the row when Slowly Changing Dimension Type 2 (SCD2) functionality is used.',
  `DW_STOP_DATE` timestamp NOT NULL default '2036-12-31 00:00:00' COMMENT 'The stop date for the row when Slowly Changing Dimension Type 2 (SCD2) functionality is used.',
  `DW_LOAD_DATE` timestamp NOT NULL default CURRENT_TIMESTAMP COMMENT 'The date the row was inserted or updated into the data warehouse table.',
  PRIMARY KEY  (`REFERER_URL_SK`),
  UNIQUE KEY `DIMENSION_WEBSITE_REFERRE_PK` (`REFERER_URL_SK`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 DELAY_KEY_WRITE=1 COMMENT='The web site referer dimension.';

CREATE TABLE `DIMENSION_WEB_VISITOR` (
  `WEB_VISITOR_SK` bigint(20) NOT NULL COMMENT 'The web site visitor surrogate key.  This key should be loaded from a database sequence or be defined as an identity column.',
  `WEB_VISITOR_LOGIN_NAME` varchar(60) default 'Missing' COMMENT 'The web visitor login name (rarely used).',
  `WEB_VISITOR_FULL_NAME` varchar(60) default 'Missing' COMMENT 'The web visitor full name (rarely used).',
  `WEB_BROWSER_OS_DESC` varchar(255) default 'Missing' COMMENT 'The web browser operating system description.',
  `IP_ADDRESS_DESC` varchar(2000) default 'Missing' COMMENT 'The IP address description, e.g., 192.168.0.100.',
  `LONG_IP_NUMBER` bigint(20) default NULL COMMENT 'The long IP address.',
  `WEB_ORGANIZATION_DESC` varchar(255) default 'Missing' COMMENT 'The web organization description.',
  `WEB_BROWSER_OS_SK` bigint(20) NOT NULL default '0' COMMENT 'The web browser operating system description.',
  `GEO_LOCATION_SK` bigint(20) default '0' COMMENT 'The geographic location surrogate key.  This relates to the geographic location dimension.  It is included in this dimesion to allow dimensional analysis without joining to a large fact table.',
  `CITY_NAME` varchar(60) default NULL COMMENT 'The city name.',
  `REGION_CODE` varchar(32) default NULL COMMENT 'The region code (state, province, department, etc.).',
  `REGION_NAME` varchar(60) character set utf8 default NULL COMMENT 'The region name (state, province, department, etc.).',
  `POSTAL_CODE` varchar(32) default NULL COMMENT 'The postal code.',
  `COUNTRY_CODE` varchar(32) default NULL COMMENT 'The country code.',
  `COUNTRY_NAME` varchar(60) default NULL COMMENT 'The country name.',
  `LATITUDE_NUMBER` decimal(7,4) default NULL COMMENT 'The latitude number.',
  `LONGITUDE_NUMBER` decimal(7,4) default NULL COMMENT 'The longitude number.',
  `DMA_CODE` smallint(6) default NULL COMMENT 'The designated marketing area (DMA) code.',
  `DMA_NAME` varchar(60) COMMENT 'The designated marketing area (DMA) name.',
  `PHONE_REGION_CODE` smallint(6) default NULL COMMENT 'The telephone region (area) code.',
  `TIMEZONE_DESC` varchar(255) default NULL COMMENT 'The timezone description.',
  `ROBOT_IND` char(1) default NULL COMMENT 'This denotes if a visitor is a Robot.',
  `DW_VERSION_NUMBER` smallint(6) default '1' COMMENT 'The version number for the row.',
  `DW_CURRENT_IND` char(1) default 'Y' COMMENT 'The current row for a particular entity when Slowly Changing Dimension Type 2 (SCD2) functionality is used.',
  `DW_START_DATE` timestamp NOT NULL default '1971-01-01 00:00:00' COMMENT 'The start date for the row when Slowly Changing Dimension Type 2 (SCD2) functionality is used.',
  `DW_STOP_DATE` timestamp NOT NULL default '2036-12-31 00:00:00' COMMENT 'The stop date for the row when Slowly Changing Dimension Type 2 (SCD2) functionality is used.',
  `DW_LOAD_DATE` timestamp NOT NULL default CURRENT_TIMESTAMP COMMENT 'The date the row was inserted or updated into the data warehouse table.',
  PRIMARY KEY  (`WEB_VISITOR_SK`),
  UNIQUE KEY `DIMENSION_WEB_VISITOR_PK` (`WEB_VISITOR_SK`),
  KEY `DIM_WEB_VISITOR_GEO_LOC_FK` (`GEO_LOCATION_SK`),
  KEY `DIM_WEB_VISITOR_BROW_OS_FK` (`WEB_BROWSER_OS_SK`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 DELAY_KEY_WRITE=1 COMMENT='The web visitor dimension.';

CREATE TABLE `FACT_WEB_PAGE_VIEW` (
  `REQUEST_DATE` datetime NOT NULL COMMENT 'The web page request date.',
  `WEB_VISITOR_SK` bigint(20) NOT NULL default '0' COMMENT 'The web visitor surrogate key.  This relates to the web visitor dimension.',
  `WEB_FILE_SK` int(11) NOT NULL default '0' COMMENT 'The web file surrogate key.  This relates to the web file dimension.',
  `SOURCE_SYSTEM_SK` int(11) NOT NULL default '0' COMMENT 'The source system surrogate key.  All dimensions and base grain fact tables must include this column to enable multiple source system capabililty.',
  `REQUEST_DATE_SK` int(11) NOT NULL default '0' COMMENT 'The page request date surrogate key.',
  `REQUEST_TIME_SK` int(11) default '0' COMMENT 'The time of day surrogate key.  This relates to the time dimension.',
  `GEO_LOCATION_SK` int(11) NOT NULL default '0' COMMENT 'The geographic location surrogate key.  This relates to the geographic location dimension.',
  `REFERER_URL_SK` int(11) NOT NULL default '0' COMMENT 'The web site referer surrogate key.  This relates to the web site referer dimension.',
  `WEB_BROWSER_OS_SK` int(11) NOT NULL default '0' COMMENT 'The web browser operating system surrogate key.  This relates to the web browser operating system dimension.',
  `WEB_FILE_BYTE_QTY` int(11) default '0' COMMENT 'The web file byte quantity.',
  `WEB_PAGE_VIEW_QTY` tinyint(4) default '1' COMMENT 'The web page view quantity.',
  `ROBOT_PAGE_VIEW_QTY` tinyint(4) default '0' COMMENT 'The robot/crawler/spider view quantity.',
  `DW_LOAD_DATE` timestamp NOT NULL default CURRENT_TIMESTAMP COMMENT 'The date the row was inserted or update in the table.',
  PRIMARY KEY  USING BTREE (`WEB_VISITOR_SK`,`REQUEST_DATE`,`WEB_FILE_SK`,`SOURCE_SYSTEM_SK`),
  KEY `FACT_WEB_PAGE_VIEW_AK` (`REQUEST_DATE`,`WEB_VISITOR_SK`,`WEB_FILE_SK`,`SOURCE_SYSTEM_SK`),
  KEY `FACT_WEB_PAGE_VIEW_TIME_FK` (`REQUEST_TIME_SK`),
  KEY `FACT_WEB_PAGE_VIEW_FILE_BI` (`WEB_FILE_SK`),
  KEY `FACT_WEB_PAGE_VIEW_SOURCE_BI` (`SOURCE_SYSTEM_SK`),
  KEY `FACT_WEB_PAGE_VIEW_VISITOR_BI` (`WEB_VISITOR_SK`),
  KEY `FACT_WEB_PAGE_VIEW_BROWSER_BI` (`WEB_BROWSER_OS_SK`),
  KEY `FACT_WEB_PAGE_VIEW_REFER_BI` (`REFERER_URL_SK`),
  KEY `FACT_WEB_PAGE_VIEW_LOC_BI` (`GEO_LOCATION_SK`),
  KEY `FACT_WEB_PAGE_VIEW_DATE_BI` (`REQUEST_DATE_SK`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 DELAY_KEY_WRITE=1 COMMENT='This fact table maintains web page viewing activity.';


CREATE TABLE `FACT_WEB_SITE_REFERER` (
  `REFERRAL_DATE_SK` int(11) NOT NULL default '0' COMMENT 'The referral date surrogate key.  This column may be used to partition the fact table by time.',
  `REFERER_URL_SK` int(11) NOT NULL default '0' COMMENT 'The web site referer surrogate key.  This relates to the web site referer dimension.',
  `WEB_FILE_SK` int(11) NOT NULL default '0' COMMENT 'The web file surrogate key.  This relates to the web file dimension.',
  `GEO_LOCATION_SK` int(11) NOT NULL default '0' COMMENT 'The geographic location surrogate key.  This relates to the geographic location dimension.',
  `WEB_VISITOR_SK` bigint(20) NOT NULL default '0' COMMENT 'The web visitor surrogate key.  This relates to the web visitor dimension.',
  `SOURCE_SYSTEM_SK` int(11) NOT NULL default '0' COMMENT 'The source system surrogate key (in the case of web server logs, this will be the parent key).  All dimensions and base grain fact tables must include this column to enable multiple source system capabililty.',
  `REFERRAL_QTY` int(11) default '1' COMMENT 'The referral quantity.',
  `WEB_FILE_BYTE_QTY` int(11) default '0' COMMENT 'The web file byte quantity.',
  `WEB_PAGE_VIEW_QTY` int(11) default '1' COMMENT 'The web page view quantity.',
  `DW_LOAD_DATE` timestamp NOT NULL default CURRENT_TIMESTAMP COMMENT 'The date the row was inserted or updated into the data warehouse table.',
  UNIQUE KEY `FACT_WEB_SITE_REFERER_AK` USING BTREE (`WEB_VISITOR_SK`,`GEO_LOCATION_SK`,`REFERER_URL_SK`,`REFERRAL_DATE_SK`,`WEB_FILE_SK`,`SOURCE_SYSTEM_SK`),
  KEY `FACT_WEB_SITE_SOURCE_BI` (`SOURCE_SYSTEM_SK`),
  KEY `FACT_WEB_SITE_REF_WEB_FILE_BI` (`WEB_FILE_SK`),
  KEY `FACT_WEB_SITE_REF_DAY_BI` (`REFERRAL_DATE_SK`),
  KEY `FACT_WEB_SITE_REF_LOC_BI` (`GEO_LOCATION_SK`),
  KEY `FACT_WEB_SITE_REF_VISITOR_BI` (`WEB_VISITOR_SK`),
  KEY `FACT_WEB_SITE_REF_REFERER_BI` (`REFERER_URL_SK`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 DELAY_KEY_WRITE=1;


CREATE TABLE `FACT_WEB_SITE_VISIT` (
  `VISIT_DATE_SK` int(11) NOT NULL default '0' COMMENT 'The visit date surrogate key.  This column may be used to partition the fact table by time.',
  `SOURCE_SYSTEM_SK` int(11) NOT NULL default '0' COMMENT 'The source system surrogate key (in the case of web server logs, this will be the parent key).  All dimensions and base grain fact tables must include this column to enable multiple source system capability.',
  `GEO_LOCATION_SK` int(11) NOT NULL default '0' COMMENT 'The geographic location surrogate key.  This relates to the geographic location dimension.',
  `WEB_VISITOR_SK` bigint(20) NOT NULL default '0' COMMENT 'The web visitor surrogate key.  This relates to the web visitor dimension.',
  `REFERER_URL_SK` int(11) NOT NULL default '0' COMMENT 'The web site referer surrogate key.  This relates to the web site referer dimension.',
  `WEB_BROWSER_OS_SK` int(11) NOT NULL default '0' COMMENT 'The web browser operating system surrogate key.  This relates to the web browser operating system dimension.',
  `VISIT_DATE` datetime default NULL COMMENT 'The visit date.  This column may be used to partition the fact table by time.',
  `WEB_VISIT_QTY` int(11) default '1' COMMENT 'The web visit quantity.',
  `WEB_FILE_BYTE_QTY` int(11) default '0' COMMENT 'The web file byte quantity.',
  `WEB_PAGE_VIEW_QTY` int(11) default '0' COMMENT 'The web page view quantity.',
  `ROBOT_PAGE_VIEW_QTY` int(11) default '0' COMMENT 'The robot/crawler/spider view quantity.',
  `DW_LOAD_DATE` timestamp NOT NULL default CURRENT_TIMESTAMP COMMENT 'The date the row was inserted or updated into the data warehouse table.',
  PRIMARY KEY  USING BTREE (`WEB_VISITOR_SK`,`GEO_LOCATION_SK`,`VISIT_DATE_SK`,`SOURCE_SYSTEM_SK`),
  KEY `FACT_WEB_SITE_VISIT_SOURCE_BI` (`SOURCE_SYSTEM_SK`),
  KEY `FACT_WEB_SITE_VISIT_DAY_BI` (`VISIT_DATE_SK`),
  KEY `FACT_WEB_SITE_VISIT_BROWSER_BI` (`WEB_BROWSER_OS_SK`),
  KEY `FACT_WEB_SITE_VISIT_VISITOR_BI` (`WEB_VISITOR_SK`),
  KEY `FACT_WEB_VISIT_LOC_BI` (`GEO_LOCATION_SK`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 DELAY_KEY_WRITE=1 COMMENT='Aggregates the web page viewing activity to a visitor visit.';



CREATE TABLE `STAGE_GEO_CITY_BLOCKS` (
  `LONG_IP_START_NUMBER` bigint(20) NOT NULL COMMENT 'The start number for the web organization long IP range.',
  `LONG_IP_END_NUMBER` bigint(20) NOT NULL COMMENT 'The end number for the web organization long IP range.',
  `GEO_LOCATION_ID` bigint(20) NOT NULL COMMENT 'The geographic location identifier in the source system.  Alone, or in combination with other columns (e.g., business unit, setid, source system), this value uniquely identifiers a geographic location in the source.',
  `DW_ERROR_IND` char(1) default 'N' COMMENT 'This denotes if a particular row in the staging table has failed a previous load attempt.',
  `DW_SOFT_DELETE_IND` char(1) default 'N' COMMENT 'This denotes that a row in the stage table has been soft-deleted.  Soft deleted have been sucessfully loaded into the data warehouse.',
  `DW_LOAD_DATE` timestamp NOT NULL default CURRENT_TIMESTAMP COMMENT 'The date the row was inserted or updated into the data warehouse table.',
  PRIMARY KEY  (`LONG_IP_START_NUMBER`,`LONG_IP_END_NUMBER`,`GEO_LOCATION_ID`),
  UNIQUE KEY `STAGE_GEO_CITY_BLOCKS_UK` (`LONG_IP_START_NUMBER`,`LONG_IP_END_NUMBER`,`GEO_LOCATION_ID`),
  KEY `STAGE_GEO_CITY_BLOCKS_LOC_FK` (`GEO_LOCATION_ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='This stage table maintains MaxMind GeoLite City data.';


 
CREATE TABLE `STAGE_GEO_CITY_LOCATION` (
  `GEO_LOCATION_ID` bigint(20) NOT NULL COMMENT 'The geographic location identifier in the source system.',
  `ISO_3166_COUNTRY_CODE` varchar(3) default NULL COMMENT 'ISO 3166 Country Codes',
  `GEO_REGION_CODE` varchar(2) default NULL COMMENT 'If the country code is US or CA (USA or Canda), then this is the ISO code, otherwise it is the FIPS code.',
  `CITY_NAME` varchar(60) character set utf8 default NULL COMMENT 'The city name.',
  `POSTAL_CODE` varchar(32) default NULL COMMENT 'The postal code.',
  `LATITUDE_NUMBER` decimal(7,4) default NULL COMMENT 'This page contains the average latitude for US States and Territories or Countries.',
  `LONGITUDE_NUMBER` decimal(7,4) default NULL COMMENT 'This page contains the average longitude for US States and Territories or Countries.',
  `DMA_CODE` double default NULL COMMENT 'The Designated Market Areas (DMA) code.',
  `PHONE_REGION_CODE` double default NULL COMMENT 'The phone region (area, city) code.',
  `DW_ERROR_IND` char(1) default 'N' COMMENT 'This denotes if a particular row in the staging table has failed a previous load attempt.',
  `DW_SOFT_DELETE_IND` char(1) default 'N' COMMENT 'This denotes that a row in the stage table has been soft-deleted.  Soft deleted have been sucessfully loaded into the data warehouse.',
  `DW_LOAD_DATE` timestamp NOT NULL default CURRENT_TIMESTAMP COMMENT 'The date the row was inserted or updated into the data warehouse table.',
  PRIMARY KEY  (`GEO_LOCATION_ID`),
  UNIQUE KEY `STAGE_GEO_CITY_LOCATION_PK` (`GEO_LOCATION_ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='This stage table maintains MaxMind World Cities information.';

 
 
CREATE TABLE `STAGE_GEO_DMA` (
  `DMA_CODE` varchar(32) NOT NULL COMMENT 'The designated marketing area (DMA) code.',
  `DMA_NAME` varchar(60) default NULL COMMENT 'The designated marketing area (DMA) name.',
  `DW_ERROR_IND` char(1) default 'N' COMMENT 'This denotes if a particular row in the staging table has failed a previous load attempt.',
  `DW_SOFT_DELETE_IND` char(1) default 'N' COMMENT 'This denotes that a row in the stage table has been soft-deleted.  Soft deleted have been sucessfully loaded into the data warehouse.',
  `DW_LOAD_DATE` timestamp NOT NULL default CURRENT_TIMESTAMP COMMENT 'The date the row was inserted or updated into the data warehouse table.',
  PRIMARY KEY  (`DMA_CODE`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='This stage table maintains DMA information.';

 
CREATE TABLE `STAGE_GEO_ISO_COUNTRY` (
  `ISO_3166_COUNTRY_CODE` varchar(32) NOT NULL COMMENT 'The ISO 3166 country code.',
  `ISO_3166_COUNTRY_NAME` varchar(60) default NULL COMMENT 'The ISO 3166 country name.',
  `DW_ERROR_IND` char(1) default 'N' COMMENT 'This denotes if a particular row in the staging table has failed a previous load attempt.',
  `DW_SOFT_DELETE_IND` char(1) default 'N' COMMENT 'This denotes that a row in the stage table has been soft-deleted.  Soft deleted have been sucessfully loaded into the data warehouse.',
  `DW_LOAD_DATE` timestamp NOT NULL default CURRENT_TIMESTAMP COMMENT 'The date the row was inserted or updated into the data warehouse table.',
  PRIMARY KEY  (`ISO_3166_COUNTRY_CODE`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='This stage table maintains ISO country information.';


 
CREATE TABLE `STAGE_GEO_ISO_COUNTRY_FIPS_REG` (
  `ISO_3166_COUNTRY_CODE` varchar(32) NOT NULL COMMENT 'The ISO 3166 country code.',
  `FIPS_10_4_REGION_CODE` varchar(32) NOT NULL default 'Missing' COMMENT 'The FIPS 10-4 region code.',
  `FIPS_10_4_REGION_NAME` varchar(60) character set utf8 default NULL COMMENT 'The FIPS 10-4 region name.',
  `DW_ERROR_IND` char(1) default 'N' COMMENT 'This denotes if a particular row in the staging table has failed a previous load attempt.',
  `DW_SOFT_DELETE_IND` char(1) default 'N' COMMENT 'This denotes that a row in the stage table has been soft-deleted.  Soft deleted have been sucessfully loaded into the data warehouse.',
  `DW_LOAD_DATE` timestamp NOT NULL default CURRENT_TIMESTAMP COMMENT 'The date the row was inserted or updated into the data warehouse table.',
  PRIMARY KEY  (`ISO_3166_COUNTRY_CODE`,`FIPS_10_4_REGION_CODE`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='This maintains ISO country & FIPS region information.';

 
CREATE TABLE `STAGE_GEO_ISO_COUNTRY_ISO_REG` (
  `ISO_3166_COUNTRY_CODE` varchar(32) NOT NULL COMMENT 'The ISO 3166 country code.',
  `ISO_3166_2_REGION_CODE` varchar(32) NOT NULL COMMENT 'The ISO 3166-2 region code.',
  `ISO_3166_2_REGION_NAME` varchar(60) default NULL COMMENT 'The ISO 3166-2 region name.',
  `DW_ERROR_IND` char(1) default 'N' COMMENT 'This denotes if a particular row in the staging table has failed a previous load attempt.',
  `DW_SOFT_DELETE_IND` char(1) default 'N' COMMENT 'This denotes that a row in the stage table has been soft-deleted.  Soft deleted have been sucessfully loaded into the data warehouse.',
  `DW_LOAD_DATE` timestamp NOT NULL default CURRENT_TIMESTAMP COMMENT 'The date the row was inserted or updated into the data warehouse table.',
  PRIMARY KEY  (`ISO_3166_COUNTRY_CODE`,`ISO_3166_2_REGION_CODE`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='This maintains ISO country and region information.';


 
CREATE TABLE `STAGE_GEO_ORGANIZATION` (
  `LONG_IP_START_NUMBER` bigint(20) NOT NULL COMMENT 'The start number for the web organization long IP range.',
  `LONG_IP_END_NUMBER` bigint(20) NOT NULL COMMENT 'The end number for the web organization long IP range.',
  `WEB_ORGANIZATION_DESC` varchar(255) NOT NULL COMMENT 'The web organization description.',
  `DW_ERROR_IND` char(1) default 'N' COMMENT 'This denotes if a particular row in the staging table has failed a previous load attempt.',
  `DW_SOFT_DELETE_IND` char(1) default 'N' COMMENT 'This denotes that a row in the stage table has been soft-deleted.  Soft deleted have been sucessfully loaded into the data warehouse.',
  `DW_LOAD_DATE` timestamp NOT NULL default CURRENT_TIMESTAMP COMMENT 'The date the row was inserted or updated into the data warehouse table.',
  PRIMARY KEY  (`LONG_IP_START_NUMBER`,`LONG_IP_END_NUMBER`,`WEB_ORGANIZATION_DESC`),
  UNIQUE KEY `STAGE_GEO_ORGANIZATION_UK` (`LONG_IP_START_NUMBER`,`LONG_IP_END_NUMBER`,`WEB_ORGANIZATION_DESC`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='This stage table maintains MaxMind organization data.';

 
CREATE TABLE `STAGE_WEB_REQUEST` (
  `IP_ADDRESS_DESC` varchar(2000) default NULL COMMENT 'The IP address description, e.g., 192.168.0.100.',
  `LONG_IP_NUMBER` bigint(20) default NULL COMMENT 'The long IP address.',
  `SOURCE_SYSTEM_ID` double default '1' COMMENT 'The source system identifier.  All dimensions and base grain fact tables must include this column to enable multiple source system capabililty.',
  `REQUEST_DATE` datetime default NULL COMMENT 'The web page request date.',
  `REQUEST_DATE_SK` bigint(20) unsigned default NULL COMMENT 'The page request date surrogate key, fomat YYYYMMDD.',
  `REQUEST_TIME_ID` varchar(32) default NULL COMMENT 'The web server request time identifier - format HH24MI, e.g., 2109.',
  `WEB_VISITOR_LOGIN_NAME` varchar(60) default 'Missing' COMMENT 'The web visitor login name (rarely used).',
  `WEB_VISITOR_FULL_NAME` varchar(60) default 'demo' COMMENT 'The web visitor full name (rarely used).',
  `WEB_FILE_NAME` varchar(4000) default NULL COMMENT 'The web file name (e.g., /etl_maps.html).',
  `REQUEST_CAT` varchar(32) default NULL COMMENT 'The web server request type (e.g., GET).',
  `HTTP_VERSION_NAME` varchar(255) default NULL COMMENT 'The HTTP version name, e.g., HTTP/1.1.',
  `SERVER_STATUS_CODE` varchar(32) default NULL COMMENT 'The web server status code, e.g., 404, 401, 200, 304, etc.',
  `WEB_FILE_BYTE_QTY` double default '0' COMMENT 'The web file byte quantity.',
  `REFERER_URL_DESC` varchar(4000) default NULL COMMENT 'The referer URL description.',
  `WEB_BROWSER_OS_DESC` varchar(255) default NULL COMMENT 'The web browser operating system description.',
  `GMT_OFFSET_CAT` varchar(32) default NULL COMMENT 'The GMT offset category, e.g., -0700.',
  `MINUTE_QTY` decimal(2,0) default NULL COMMENT 'The minute value from the request time.',
  `HOUR_24_QTY` decimal(2,0) default NULL COMMENT 'The hour value from the request time.',
  `ROBOT_PAGE_VIEW_QTY` double default '0' COMMENT 'The robot/crawler/spider view quantity.',
  `DW_ERROR_IND` char(1) default 'N' COMMENT 'This denotes if a particular row in the staging table has failed a previous load attempt.',
  `DW_SOFT_DELETE_IND` char(1) default 'N' COMMENT 'This denotes that a row in the stage table has been soft-deleted.  Soft deleted have been sucessfully loaded into the data warehouse.',
  `DW_LOAD_DATE` timestamp NOT NULL default CURRENT_TIMESTAMP COMMENT 'The date the row was inserted or updated into the data warehouse table.',
  KEY `STG_WEB_SERVER_REQUEST_IDX` (`LONG_IP_NUMBER`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='This stage table maintains raw data from the web server log.';



CREATE TABLE `STAGE_WEB_VISITOR` (
  `WEB_VISITOR_FULL_NAME` varchar(60) NOT NULL default 'demo' COMMENT 'The web visitor full name (rarely used).',
  `LONG_IP_NUMBER` bigint(20) NOT NULL COMMENT 'The long IP address.',
  `WEB_VISITOR_LOGIN_NAME` varchar(60) default 'Missing' COMMENT 'The web visitor login name (rarely used).',
  `WEB_BROWSER_OS_DESC` varchar(255) default NULL COMMENT 'The web browser operating system description.',
  `IP_ADDRESS_DESC` varchar(2000) default NULL COMMENT 'The IP address description.',
  `DW_ERROR_IND` char(1) default NULL COMMENT 'This denotes if a particular row in the staging table has failed a previous load attempt.',
  `DW_LOAD_DATE` timestamp NOT NULL default CURRENT_TIMESTAMP COMMENT 'The date the row was inserted or updated into the data warehouse table.',
  PRIMARY KEY  (`WEB_VISITOR_FULL_NAME`,`LONG_IP_NUMBER`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='This table lowers the cost of loading a subsequent table.';
