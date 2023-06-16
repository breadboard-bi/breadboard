/*==============================================================*/
/* DBMS name:      ORACLE Version 10g                           */
/* Name:  	   Clickstream Data Mart (open source)          */
/* Version:  	   2         					*/
/*==============================================================*/



/*==============================================================*/
/* Table: ADMIN_JOB_CONTROL                                     */
/*==============================================================*/
create table ADMIN_JOB_CONTROL  (
   ID_JOB               VARCHAR2(50),
   JOBNAME              VARCHAR2(50),
   STATUS               VARCHAR2(15),
   LINES_READ           NUMBER(10),
   LINES_WRITTEN        NUMBER(10),
   LINES_UPDATED        NUMBER(10),
   LINES_INPUT          NUMBER(10),
   LINES_OUTPUT         NUMBER(10),
   ERRORS               NUMBER(10),
   STARTDATE            DATE,
   ENDDATE              DATE,
   LOGDATE              DATE,
   DEPDATE              DATE,
   REPLAYDATE           DATE,
   LOG_FIELD            CLOB
);

comment on table ADMIN_JOB_CONTROL is
'This job control table maintains information about Pentaho jobs.  It is loaded by Chef automatically after each job run.';

comment on column ADMIN_JOB_CONTROL.ID_JOB is
'ID_JOB';

comment on column ADMIN_JOB_CONTROL.JOBNAME is
'JOBNAME';

comment on column ADMIN_JOB_CONTROL.STATUS is
'STATUS';

comment on column ADMIN_JOB_CONTROL.LINES_READ is
'LINES_READ';

comment on column ADMIN_JOB_CONTROL.LINES_WRITTEN is
'LINES_WRITTEN';

comment on column ADMIN_JOB_CONTROL.LINES_UPDATED is
'LINES_UPDATED';

comment on column ADMIN_JOB_CONTROL.LINES_INPUT is
'LINES_INPUT';

comment on column ADMIN_JOB_CONTROL.LINES_OUTPUT is
'LINES_OUTPUT';

comment on column ADMIN_JOB_CONTROL.ERRORS is
'ERRORS';

comment on column ADMIN_JOB_CONTROL.STARTDATE is
'STARTDATE';

comment on column ADMIN_JOB_CONTROL.ENDDATE is
'ENDDATE';

comment on column ADMIN_JOB_CONTROL.LOGDATE is
'LOGDATE';

comment on column ADMIN_JOB_CONTROL.DEPDATE is
'DEPDATE';

comment on column ADMIN_JOB_CONTROL.REPLAYDATE is
'REPLAYDATE';

comment on column ADMIN_JOB_CONTROL.LOG_FIELD is
'LOG_FIELD';

  CREATE TABLE DIMENSION_SOURCE_SYSTEM 
   (	SOURCE_SYSTEM_SK NUMBER, 
	SOURCE_SYSTEM_ID VARCHAR2(32 BYTE), 
	SOURCE_SYSTEM_NAME VARCHAR2(60 BYTE), 
	SOURCE_SYSTEM_DESC VARCHAR2(255 BYTE), 
	CONTACT_NAME VARCHAR2(60 BYTE), 
	CONTACT_EMAIL_DESC VARCHAR2(255 BYTE), 
	DW_LOAD_DATE DATE DEFAULT SYSDATE, 
	 PRIMARY KEY (SOURCE_SYSTEM_SK) ENABLE
   ) ;

  CREATE UNIQUE INDEX MDW.DIMENSION_SOURCE_SYSTEM_PK ON MDW.DIMENSION_SOURCE_SYSTEM (SOURCE_SYSTEM_SK) 
  ;

comment on table DIMENSION_SOURCE_SYSTEM is
'The source system table maintains information about the systems source by the MDW.  Data is entered manually (or using some other method) by the analytics team.';

comment on column DIMENSION_SOURCE_SYSTEM.SOURCE_SYSTEM_SK is 'The source system surrogate key.  The SOURCE_SYSTEM_SK and SOURCE_SYSTEM_ID should 
be valued exactly the same, i.e., for a given source system with a SOURCE_SYSTEM_ID = 1, the SOURCE_SYSTEM_SK will also be = 1.  Both the 
SOURCE_SYSTEM_ID and the SOURCE_SYSTEM_SK are “owned” by your client’s analytics team – they will have no meaning outside of this context.';

comment on column DIMENSION_SOURCE_SYSTEM.SOURCE_SYSTEM_ID is 'The source system identifier.  The SOURCE_SYSTEM_SK and SOURCE_SYSTEM_ID should be valued exactly 
the same, i.e., for a given source system with a SOURCE_SYSTEM_ID = 1, the SOURCE_SYSTEM_SK will also be = 1.  Both the SOURCE_SYSTEM_ID and 
the SOURCE_SYSTEM_SK are “owned” by your client’s analytics team – they will have no meaning outside of this context.';

comment on column DIMENSION_SOURCE_SYSTEM.SOURCE_SYSTEM_NAME is 'The source system name.';

comment on column DIMENSION_SOURCE_SYSTEM.SOURCE_SYSTEM_DESC is 'The source system description.';

comment on column DIMENSION_SOURCE_SYSTEM.CONTACT_NAME is 'The source system contact person name.';

comment on column DIMENSION_SOURCE_SYSTEM.CONTACT_EMAIL_DESC is 'The source system contact person email address.';

comment on column DIMENSION_SOURCE_SYSTEM.DW_LOAD_DATE is 'The date the row was inserted or updated into the data warehouse table.';


/*==============================================================*/
/* Table: DIMENSION_DAY                                         */
/*==============================================================*/
create table DIMENSION_DAY  (
   DATE_SK              NUMBER                          not null,
   DAY_DATE             DATE,
   DAY_NAME             VARCHAR2(60),
   MONTH_SK             NUMBER,
   MONTH_NUMBER         NUMBER,
   MONTH_NAME           VARCHAR2(60),
   QUARTER_SK           NUMBER,
   QUARTER_NUMBER       NUMBER,
   QUARTER_NAME         VARCHAR2(60),
   DAY_OF_WEEK_NUMBER   NUMBER,
   DAY_OF_MONTH_NUMBER  NUMBER,
   DAYS_IN_MONTH_QTY    NUMBER,
   DAY_OF_YEAR_NUMBER   NUMBER,
   WEEK_OF_MONTH_NUMBER NUMBER,
   WEEK_OF_QUARTER_NUMBER NUMBER,
   WEEK_OF_YEAR_NUMBER  NUMBER,
   WEEKEND_IND          CHAR,
   WEEK_OF_MONTH_NAME   VARCHAR2(60),
   YEAR_QUARTER_NAME    VARCHAR2(60),
   DAY_DESC             VARCHAR2(32),
   DAY_OF_WEEK_SORT_NAME VARCHAR2(60),
   WEEK_SK              NUMBER,
   WEEK_NAME            VARCHAR2(60),
   WEEK_DESC            VARCHAR2(255),
   YEAR_SK              NUMBER                         default 0,
   YEAR_SORT_NUMBER     VARCHAR2(4),
   YEAR_NUMBER          NUMBER,
   DW_VERSION_NUMBER    NUMBER                         default 1,
   DW_CURRENT_IND       CHAR                           default 'Y',
   DW_START_DATE        DATE                           default '01-JAN-1970',
   DW_STOP_DATE         DATE                           default '31-DEC-2036',
   DW_LOAD_DATE         DATE                           default SYSDATE,
   constraint DIMENSION_DAY_PK primary key (DATE_SK)
         
   using index
      nologging
);

comment on table DIMENSION_DAY is
'The day (date) dimension.';

comment on column DIMENSION_DAY.DATE_SK is
'The day surrogate key.  This smart key is loaded with the date value in the format YYYYMMDD.';

comment on column DIMENSION_DAY.DAY_DATE is
'The date (date datatype).';

comment on column DIMENSION_DAY.DAY_NAME is
'The name of the day, e.g., Monday.';

comment on column DIMENSION_DAY.MONTH_SK is
'The month surrogate key.  Relates to the month dimension (if needed for aggregate fact tables).';

comment on column DIMENSION_DAY.MONTH_NUMBER is
'The month number (1-12).';

comment on column DIMENSION_DAY.MONTH_NAME is
'The month name, e.g. January.';

comment on column DIMENSION_DAY.QUARTER_SK is
'The quarter surrogate key.  Relates to the quarter dimension (if needed for aggregate fact tables).';

comment on column DIMENSION_DAY.QUARTER_NUMBER is
'The quarter number (1-4).';

comment on column DIMENSION_DAY.QUARTER_NAME is
'The quarter name, e.g., Q1.';

comment on column DIMENSION_DAY.DAY_OF_WEEK_NUMBER is
'The day of the week number (1-7).';

comment on column DIMENSION_DAY.DAY_OF_MONTH_NUMBER is
'The day of month number (1-31).';

comment on column DIMENSION_DAY.DAYS_IN_MONTH_QTY is
'The number of days in a given month.';

comment on column DIMENSION_DAY.DAY_OF_YEAR_NUMBER is
'The day of year number (1-366).';

comment on column DIMENSION_DAY.WEEK_OF_MONTH_NUMBER is
'The week of month number (1-5).';

comment on column DIMENSION_DAY.WEEK_OF_QUARTER_NUMBER is
'The week of quarter number.';

comment on column DIMENSION_DAY.WEEK_OF_YEAR_NUMBER is
'The week of year number (1-52).';

comment on column DIMENSION_DAY.WEEKEND_IND is
'This denotes if a day is a weekend (generally Saturday and Sunday).';

comment on column DIMENSION_DAY.WEEK_OF_MONTH_NAME is
'The week of month name, e.g., W1.';

comment on column DIMENSION_DAY.YEAR_QUARTER_NAME is
'The year quarter name, e.g., 2006Q1.';

comment on column DIMENSION_DAY.DAY_DESC is
'The date string in the format DD-MM-YYYY.';

comment on column DIMENSION_DAY.DAY_OF_WEEK_SORT_NAME is
'The day of week sort name used to overcome ordinal column issues in Mondrian.  Example format, Day 1 - Day 7.';

comment on column DIMENSION_DAY.WEEK_SK is
'The calendar week surrogate key.';

comment on column DIMENSION_DAY.WEEK_NAME is
'The week name.  For example, 1998W45.  Note:  this assumes week starts on Sunday.';

comment on column DIMENSION_DAY.WEEK_DESC is
'The week description.  For example, Week of September 3, 2006.  Note:  this assumes week starts on Sunday.';

comment on column DIMENSION_DAY.YEAR_SK is
'The year surrogate key.  Relates to the year dimension (if needed for aggregate fact tables).';

comment on column DIMENSION_DAY.YEAR_SORT_NUMBER is
'This column is defined as a varchar datatype to allow for proper Mondrian drill-through formatting.';

comment on column DIMENSION_DAY.YEAR_NUMBER is
'YEAR_NUMBER';

comment on column DIMENSION_DAY.DW_VERSION_NUMBER is
'The version number for the row.';

comment on column DIMENSION_DAY.DW_CURRENT_IND is
'The current row for a particular entity when Slowly Changing Dimension Type 2 (SCD2) functionality is used..';

comment on column DIMENSION_DAY.DW_START_DATE is
'The start date for the row when Slowly Changing Dimension Type 2 (SCD2) functionality is used.';

comment on column DIMENSION_DAY.DW_STOP_DATE is
'The stop date for the row when Slowly Changing Dimension Type 2 (SCD2) functionality is used.';

comment on column DIMENSION_DAY.DW_LOAD_DATE is
'The date the row was inserted or updated into the data warehouse table.';

/*==============================================================*/
/* Index: DIMENSION_DAY_AK                                      */
/*==============================================================*/
create unique index DIMENSION_DAY_AK on DIMENSION_DAY (
   DAY_DATE ASC
)
;

/*==============================================================*/
/* Table: DIMENSION_GEOGRAPHIC_LOCATION                         */
/*==============================================================*/
create table DIMENSION_GEOGRAPHIC_LOCATION  (
   GEO_LOCATION_SK      NUMBER                         default 0 not null,
   GEO_LOCATION_ID      NUMBER                         default 0 not null,
   SOURCE_SYSTEM_SK     NUMBER                         default 1,
   ISO_3166_COUNTRY_CODE VARCHAR2(32)                   default '-',
   ISO_3166_COUNTRY_NAME VARCHAR2(60)                   default 'Missing',
   ISO_3166_2_REGION_CODE VARCHAR2(32)                   default '-',
   ISO_3166_2_REGION_NAME VARCHAR2(60)                   default 'Missing',
   FIPS_10_4_REGION_CODE VARCHAR2(32)                   default '-',
   FIPS_10_4_REGION_NAME VARCHAR2(60)                   default 'Missing',
   REGION_CODE          VARCHAR2(32),
   REGION_NAME          VARCHAR2(60)                   default 'Missing',
   CITY_NAME            VARCHAR2(60)                   default 'Missing',
   POSTAL_CODE          VARCHAR2(32)                   default 'Missing',
   LATITUDE_NUMBER      NUMBER(7,4),
   LONGITUDE_NUMBER     NUMBER(7,4),
   DMA_NAME             VARCHAR2(255)                  default 'Missing',
   DMA_CODE             NUMBER                         default 0,
   PHONE_REGION_CODE    NUMBER                         default 0,
   DW_VERSION_NUMBER    NUMBER(18)                     default 1,
   DW_CURRENT_IND       CHAR                           default 'Y',
   DW_START_DATE        DATE                           default '01-JAN-1970',
   DW_STOP_DATE         DATE                           default '31-DEC-2036',
   DW_LOAD_DATE         DATE                           default SYSDATE,
   constraint DIMENSION_GEO_LOCATION_PK primary key (GEO_LOCATION_SK)
         
   using index
     
        nologging,
   constraint DIMENSION_GEO_LOCATION_UK unique (GEO_LOCATION_ID)
);

comment on table DIMENSION_GEOGRAPHIC_LOCATION is
'The geographic location dimension.';

comment on column DIMENSION_GEOGRAPHIC_LOCATION.GEO_LOCATION_SK is
'The geographic location surrogate key.  This key should be loaded from a database sequence or be defined as an identity column.';

comment on column DIMENSION_GEOGRAPHIC_LOCATION.GEO_LOCATION_ID is
'The geographic location identifier in the source system.  Alone, or in combination with other columns (e.g., business unit, setid, source system), this value uniquely identifiers a geographic location in the source.';

comment on column DIMENSION_GEOGRAPHIC_LOCATION.SOURCE_SYSTEM_SK is
'The source system surrogate key.  All dimensions and base grain fact tables must include this column to enable multiple source system capabililty.';

comment on column DIMENSION_GEOGRAPHIC_LOCATION.ISO_3166_COUNTRY_CODE is
'The ISO 3166 country code.';

comment on column DIMENSION_GEOGRAPHIC_LOCATION.ISO_3166_COUNTRY_NAME is
'The ISO 3166 country name.';

comment on column DIMENSION_GEOGRAPHIC_LOCATION.ISO_3166_2_REGION_CODE is
'The ISO 3166-2 region code.';

comment on column DIMENSION_GEOGRAPHIC_LOCATION.ISO_3166_2_REGION_NAME is
'The ISO 3166-2 region name.';

comment on column DIMENSION_GEOGRAPHIC_LOCATION.FIPS_10_4_REGION_CODE is
'The FIPS 10-4 region code.';

comment on column DIMENSION_GEOGRAPHIC_LOCATION.FIPS_10_4_REGION_NAME is
'The FIPS 10-4 region name.';

comment on column DIMENSION_GEOGRAPHIC_LOCATION.REGION_CODE is
'The region name.  If the geographic location is the United States or Canada, this is the ISO 3166-2 region code, otherwise it is the FIPS 10-4 region code.';

comment on column DIMENSION_GEOGRAPHIC_LOCATION.REGION_NAME is
'The region name.  If the geographic location is the United States or Canada, this is the ISO 3166-2 region name, otherwise it is the FIPS 10-4 region name.';

comment on column DIMENSION_GEOGRAPHIC_LOCATION.CITY_NAME is
'The city name.';

comment on column DIMENSION_GEOGRAPHIC_LOCATION.POSTAL_CODE is
'This postal code.';

comment on column DIMENSION_GEOGRAPHIC_LOCATION.LATITUDE_NUMBER is
'The latitude number for the city.';

comment on column DIMENSION_GEOGRAPHIC_LOCATION.LONGITUDE_NUMBER is
'The longitude number for the city.';

comment on column DIMENSION_GEOGRAPHIC_LOCATION.DMA_NAME is
'The designated marketing area (DMA) name.';

comment on column DIMENSION_GEOGRAPHIC_LOCATION.DMA_CODE is
'The designated marketing area (DMA) code.';

comment on column DIMENSION_GEOGRAPHIC_LOCATION.PHONE_REGION_CODE is
'The telephone region code.';

comment on column DIMENSION_GEOGRAPHIC_LOCATION.DW_VERSION_NUMBER is
'The version number for the row.';

comment on column DIMENSION_GEOGRAPHIC_LOCATION.DW_CURRENT_IND is
'The current row for a particular entity when Slowly Changing Dimension Type 2 (SCD2) functionality is used.';

comment on column DIMENSION_GEOGRAPHIC_LOCATION.DW_START_DATE is
'The start date for the row when Slowly Changing Dimension Type 2 (SCD2) functionality is used.';

comment on column DIMENSION_GEOGRAPHIC_LOCATION.DW_STOP_DATE is
'The stop date for the row when Slowly Changing Dimension Type 2 (SCD2) functionality is used.';

comment on column DIMENSION_GEOGRAPHIC_LOCATION.DW_LOAD_DATE is
'The date the row was inserted or updated into the data warehouse table.';

/*==============================================================*/
/* Index: DIMENSION_GEO_LOC_I                                   */
/*==============================================================*/
create index DIMENSION_GEO_LOC_I on DIMENSION_GEOGRAPHIC_LOCATION (
   ISO_3166_COUNTRY_CODE ASC,
   REGION_NAME ASC
)
;


CREATE TABLE MDW.DIMENSION_TIME 
   (	TIME_SK NUMBER NOT NULL ENABLE, 
	TIME_24_CODE VARCHAR2(32), 
	TIME_12_CODE VARCHAR2(32), 
	HOUR_24_CODE VARCHAR2(32), 
	HOUR_12_CODE VARCHAR2(32 ), 
	AM_PM_IND VARCHAR2(2), 
	MINUTE_QTY NUMBER(2,0), 
	HOUR_24_QTY NUMBER(2,0), 
	HOUR_12_QTY NUMBER(2,0),
	DW_VERSION_NUMBER NUMBER DEFAULT 1, 
	DW_CURRENT_IND CHAR(1 BYTE) DEFAULT 'Y', 
	DW_START_DATE DATE default '01-JAN-1970', 
	DW_STOP_DATE DATE default '31-DEC-2036', 
	DW_LOAD_DATE DATE DEFAULT SYSDATE,  
	CONSTRAINT DIMENSION_TIME_PK PRIMARY KEY (TIME_SK) ENABLE
   ) ;
 

CREATE UNIQUE INDEX MDW.DIMENSION_TIME_PK ON MDW.DIMENSION_TIME (TIME_SK);


/*==============================================================*/
/* Table: DIMENSION_WEB_BROWSER_OS                              */
/*==============================================================*/
create table DIMENSION_WEB_BROWSER_OS  (
   WEB_BROWSER_OS_SK    NUMBER                          not null,
   WEB_BROWSER_NAME     VARCHAR2(60),
   PARENT_WEB_BROWSER_NAME VARCHAR2(60),
   WEB_BROWSER_OS_DESC  VARCHAR2(2000),
   PARENT_OPERATING_SYSTEM_NAME VARCHAR2(60),
   OPERATING_SYSTEM_NAME VARCHAR2(60),
   DW_VERSION_NUMBER    NUMBER                         default 1,
   DW_CURRENT_IND       CHAR                           default 'Y',
   DW_START_DATE        DATE                           default '01-JAN-1970',
   DW_STOP_DATE         DATE                           default '31-DEC-2036',
   DW_LOAD_DATE         DATE                           default SYSDATE,
   constraint DIMENSION_WEB_BROWSER_OS_PK primary key (WEB_BROWSER_OS_SK)
         
   using index
    
        nologging
);

comment on table DIMENSION_WEB_BROWSER_OS is
'The web browser operating system dimension.  Every unique web browser os description from the web server log will have a row in this table.';

comment on column DIMENSION_WEB_BROWSER_OS.WEB_BROWSER_OS_SK is
'The web browser operating system surrogate key.  This key should be loaded from a database sequence or be defined as an identity column.';

comment on column DIMENSION_WEB_BROWSER_OS.WEB_BROWSER_NAME is
'The web browser name (e.g., Firefox 1.x).';

comment on column DIMENSION_WEB_BROWSER_OS.PARENT_WEB_BROWSER_NAME is
'The web browser parent name (e.g., Firefox).';

comment on column DIMENSION_WEB_BROWSER_OS.WEB_BROWSER_OS_DESC is
'The web browser/OS description (e.g., Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.0.4) Gecko/20060508 Firefox/1.5.0.4).';

comment on column DIMENSION_WEB_BROWSER_OS.PARENT_OPERATING_SYSTEM_NAME is
'The operating system name (e.g., Windows).';

comment on column DIMENSION_WEB_BROWSER_OS.OPERATING_SYSTEM_NAME is
'The operating system name (e.g., Windows 98).';

comment on column DIMENSION_WEB_BROWSER_OS.DW_VERSION_NUMBER is
'The version number for the row.';

comment on column DIMENSION_WEB_BROWSER_OS.DW_CURRENT_IND is
'The current row for a particular entity when Slowly Changing Dimension Type 2 (SCD2) functionality is used.';

comment on column DIMENSION_WEB_BROWSER_OS.DW_START_DATE is
'The start date for the row when Slowly Changing Dimension Type 2 (SCD2) functionality is used.';

comment on column DIMENSION_WEB_BROWSER_OS.DW_STOP_DATE is
'The stop date for the row when Slowly Changing Dimension Type 2 (SCD2) functionality is used.';

comment on column DIMENSION_WEB_BROWSER_OS.DW_LOAD_DATE is
'The date the row was inserted or updated into the data warehouse table.';

/*==============================================================*/
/* Table: DIMENSION_WEB_FILE                                    */
/*==============================================================*/
create table DIMENSION_WEB_FILE  (
   WEB_FILE_SK          NUMBER                          not null,
   WEB_FILE_NAME        VARCHAR2(2000)                 default 'Missing',
   WEB_FILE_URL_DESC    VARCHAR2(2000)                 default 'Missing',
   WEB_FILE_CAT         VARCHAR2(32)                   default 'Missing',
   WEB_FILE_CAT_NAME    VARCHAR2(60)                   default 'Missing',
   WEB_FILE_BYTE_QTY    NUMBER,
   DW_VERSION_NUMBER    NUMBER                         default 1,
   DW_CURRENT_IND       CHAR                           default 'Y',
   DW_START_DATE        DATE                           default '01-JAN-1970',
   DW_STOP_DATE         DATE                           default '31-DEC-2036',
   DW_LOAD_DATE         DATE                           default SYSDATE,
   constraint DIMENSION_WEBSITE_FILE_PK primary key (WEB_FILE_SK)
         
   using index
        nologging
);

comment on table DIMENSION_WEB_FILE is
'The web file dimension.';

comment on column DIMENSION_WEB_FILE.WEB_FILE_SK is
'The web file surrogate key.  This key should be loaded from a database sequence or be defined as an identity column.';

comment on column DIMENSION_WEB_FILE.WEB_FILE_NAME is
'The web file name (e.g., /etl_maps.html).';

comment on column DIMENSION_WEB_FILE.WEB_FILE_URL_DESC is
'The web file URL description (e.g., http://www.breadboardbi.com/cubes.html).';

comment on column DIMENSION_WEB_FILE.WEB_FILE_CAT is
'The web file category (e.g., html).';

comment on column DIMENSION_WEB_FILE.WEB_FILE_CAT_NAME is
'The web file category name.  This could be used to further detail the shorter category.';

comment on column DIMENSION_WEB_FILE.WEB_FILE_BYTE_QTY is
'The web file byte quantity.';

comment on column DIMENSION_WEB_FILE.DW_VERSION_NUMBER is
'The version number for the row.';

comment on column DIMENSION_WEB_FILE.DW_CURRENT_IND is
'The current row for a particular entity when Slowly Changing Dimension Type 2 (SCD2) functionality is used.';

comment on column DIMENSION_WEB_FILE.DW_START_DATE is
'The start date for the row when Slowly Changing Dimension Type 2 (SCD2) functionality is used.';

comment on column DIMENSION_WEB_FILE.DW_STOP_DATE is
'The stop date for the row when Slowly Changing Dimension Type 2 (SCD2) functionality is used.';

comment on column DIMENSION_WEB_FILE.DW_LOAD_DATE is
'The date the row was inserted or updated into the data warehouse table.';


/*==============================================================*/
/* Table: DIMENSION_WEB_SITE_REFERER                            */
/*==============================================================*/
create table DIMENSION_WEB_SITE_REFERER  (
   REFERER_URL_SK       NUMBER                          not null,
   REFERER_URL_DESC     VARCHAR2(2000)                 default 'Missing',
   PARENT_REFERER_DESC  VARCHAR2(255)                  default 'Missing',
   REFERER_DESC         VARCHAR2(255)                  default 'Missing',
   EXTERNAL_IND         VARCHAR2(1),
   DW_VERSION_NUMBER    NUMBER                         default 1,
   DW_CURRENT_IND       CHAR                           default 'Y',
   DW_START_DATE        DATE                           default '01-JAN-1970',
   DW_STOP_DATE         DATE                           default '31-DEC-2036',
   DW_LOAD_DATE         DATE                           default SYSDATE,
   constraint DIMENSION_WEBSITE_REFERER_PK primary key (REFERER_URL_SK),
   constraint DIMENSION_WEB_SITE_REFER_AK unique (REFERER_URL_DESC)
         
   using index
        nologging
);

comment on table DIMENSION_WEB_SITE_REFERER is
'The web site referer dimension.';

comment on column DIMENSION_WEB_SITE_REFERER.REFERER_URL_SK is
'The web site referer surrogate key.  This key should be loaded from a database sequence or be defined as an identity column.';

comment on column DIMENSION_WEB_SITE_REFERER.REFERER_URL_DESC is
'The referer URL description.';

comment on column DIMENSION_WEB_SITE_REFERER.PARENT_REFERER_DESC is
'The parent referer description.';

comment on column DIMENSION_WEB_SITE_REFERER.REFERER_DESC is
'The referer description.';

comment on column DIMENSION_WEB_SITE_REFERER.EXTERNAL_IND is
'This indicates if a referer page is external to the web site.';

comment on column DIMENSION_WEB_SITE_REFERER.DW_VERSION_NUMBER is
'The version number for the row.';

comment on column DIMENSION_WEB_SITE_REFERER.DW_CURRENT_IND is
'The current row for a particular entity when Slowly Changing Dimension Type 2 (SCD2) functionality is used.';

comment on column DIMENSION_WEB_SITE_REFERER.DW_START_DATE is
'The start date for the row when Slowly Changing Dimension Type 2 (SCD2) functionality is used.';

comment on column DIMENSION_WEB_SITE_REFERER.DW_STOP_DATE is
'The stop date for the row when Slowly Changing Dimension Type 2 (SCD2) functionality is used.';

comment on column DIMENSION_WEB_SITE_REFERER.DW_LOAD_DATE is
'The date the row was inserted or updated into the data warehouse table.';

/*==============================================================*/
/* Table: DIMENSION_WEB_VISITOR                                 */
/*==============================================================*/
create table DIMENSION_WEB_VISITOR  (
   WEB_VISITOR_SK       NUMBER                          not null,
   GEO_LOCATION_SK      NUMBER                         default 0,
   WEB_BROWSER_OS_SK    NUMBER                         default 0,
   WEB_VISITOR_LOGIN_NAME VARCHAR2(60)                   default 'Missing',
   WEB_VISITOR_FULL_NAME VARCHAR2(60)                   default 'Missing',
   WEB_ORGANIZATION_DESC VARCHAR2(255)                  default 'Missing',
   WEB_BROWSER_OS_DESC  VARCHAR2(255)                  default 'Missing',
   ROBOT_IND            CHAR,
   IP_ADDRESS_DESC      VARCHAR2(2000)                 default 'MIssing',
   LONG_IP_NUMBER       NUMBER,
   CITY_NAME VARCHAR2(60 BYTE), 
   REGION_CODE VARCHAR2(32 BYTE), 
   REGION_NAME VARCHAR2(60 BYTE), 
   POSTAL_CODE VARCHAR2(32 BYTE), 
   COUNTRY_CODE VARCHAR2(32 BYTE), 
   COUNTRY_NAME VARCHAR2(60 BYTE), 
   LATITUDE_NUMBER NUMBER(7,4), 
   LONGITUDE_NUMBER NUMBER(7,4), 
   DMA_CODE NUMBER, 
   DMA_NAME VARCHAR2(60),
   PHONE_REGION_CODE NUMBER, 
   TIMEZONE_DESC VARCHAR2(255 BYTE),
   DW_VERSION_NUMBER    NUMBER                         default 1,
   DW_CURRENT_IND       CHAR                           default 'Y',
   DW_START_DATE        DATE                           default '01-JAN-1970',
   DW_STOP_DATE         DATE                           default '31-DEC-2036',
   DW_LOAD_DATE         DATE                           default SYSDATE,
   constraint DIMENSION_WEB_VISITOR_PK primary key (WEB_VISITOR_SK)
         
   using index
        nologging
);

comment on table DIMENSION_WEB_VISITOR is
'The web visitor dimension.';

comment on column DIMENSION_WEB_VISITOR.WEB_VISITOR_SK is
'The web site visitor surrogate key.  This key should be loaded from a database sequence or be defined as an identity column.';

comment on column DIMENSION_WEB_VISITOR.GEO_LOCATION_SK is
'The geographic location surrogate key.  This relates to the geographic location dimension.';

comment on column DIMENSION_WEB_VISITOR.WEB_BROWSER_OS_SK is
'WEB_BROWSER_OS_SK';

comment on column DIMENSION_WEB_VISITOR.WEB_VISITOR_LOGIN_NAME is
'The web visitor login name (rarely used).';

comment on column DIMENSION_WEB_VISITOR.WEB_VISITOR_FULL_NAME is
'The web visitor full name (rarely used).';

comment on column DIMENSION_WEB_VISITOR.WEB_ORGANIZATION_DESC is
'The web organization description.';

comment on column DIMENSION_WEB_VISITOR.WEB_BROWSER_OS_DESC is
'The web browser operating system description.';

comment on column DIMENSION_WEB_VISITOR.ROBOT_IND is
'This denotes if a visitor is a Robot.';

comment on column DIMENSION_WEB_VISITOR.IP_ADDRESS_DESC is
'The IP address description, e.g., 192.168.0.100.';

comment on column DIMENSION_WEB_VISITOR.LONG_IP_NUMBER is
'The long IP address.';

COMMENT ON COLUMN DIMENSION_WEB_VISITOR.CITY_NAME IS 'The city name.';
 
COMMENT ON COLUMN DIMENSION_WEB_VISITOR.REGION_CODE IS 'The region code (state, province, department, etc.).';
 
COMMENT ON COLUMN DIMENSION_WEB_VISITOR.REGION_NAME IS 'The region name (state, province, department, etc.).';
 
COMMENT ON COLUMN DIMENSION_WEB_VISITOR.POSTAL_CODE IS 'The postal code.';
 
COMMENT ON COLUMN DIMENSION_WEB_VISITOR.COUNTRY_CODE IS 'The country code.';
 
COMMENT ON COLUMN DIMENSION_WEB_VISITOR.COUNTRY_NAME IS 'The country name.';
 
COMMENT ON COLUMN DIMENSION_WEB_VISITOR.LATITUDE_NUMBER IS 'The latitude number.';
 
COMMENT ON COLUMN DIMENSION_WEB_VISITOR.LONGITUDE_NUMBER IS 'The longitude number.';
 
COMMENT ON COLUMN DIMENSION_WEB_VISITOR.DMA_CODE IS 'The designated marketing area (DMA) code.';

COMMENT ON COLUMN DIMENSION_WEB_VISITOR.DMA_NAME IS 'The designated marketing area (DMA) name.';
 
COMMENT ON COLUMN DIMENSION_WEB_VISITOR.PHONE_REGION_CODE IS 'The telephone region (area) code.';
 
COMMENT ON COLUMN DIMENSION_WEB_VISITOR.TIMEZONE_DESC IS 'The timezone description.';

comment on column DIMENSION_WEB_VISITOR.DW_VERSION_NUMBER is
'The version number for the row.';

comment on column DIMENSION_WEB_VISITOR.DW_CURRENT_IND is
'The current row for a particular entity when Slowly Changing Dimension Type 2 (SCD2) functionality is used.';

comment on column DIMENSION_WEB_VISITOR.DW_START_DATE is
'The start date for the row when Slowly Changing Dimension Type 2 (SCD2) functionality is used.';

comment on column DIMENSION_WEB_VISITOR.DW_STOP_DATE is
'The stop date for the row when Slowly Changing Dimension Type 2 (SCD2) functionality is used.';

comment on column DIMENSION_WEB_VISITOR.DW_LOAD_DATE is
'The date the row was inserted or updated into the data warehouse table.';

/*==============================================================*/
/* Table: FACT_WEB_PAGE_VIEW                                    */
/*==============================================================*/
create table FACT_WEB_PAGE_VIEW  (
   REQUEST_DATE         DATE,
   REQUEST_DATE_SK      NUMBER                         default 0,
   REQUEST_TIME_SK      NUMBER                         default 0,
   GEO_LOCATION_SK      NUMBER                         default 0,
   REFERER_URL_SK       NUMBER                         default 0,
   WEB_FILE_SK          NUMBER                         default 0,
   WEB_VISITOR_SK       NUMBER                         default 0,
   WEB_BROWSER_OS_SK    NUMBER                         default 0,
   SOURCE_SYSTEM_SK     NUMBER                         default 1,
   WEB_FILE_BYTE_QTY    NUMBER                         default 0,
   WEB_PAGE_VIEW_QTY    NUMBER                         default 1,
   ROBOT_PAGE_VIEW_QTY  NUMBER                         default 0,
   DW_LOAD_DATE         DATE                           default SYSDATE
);

comment on table FACT_WEB_PAGE_VIEW is
'This fact table maintains the .html and .pdf web page viewing activity for web site visitors.';

comment on column FACT_WEB_PAGE_VIEW.REQUEST_DATE is
'The web page request date.';

comment on column FACT_WEB_PAGE_VIEW.REQUEST_DATE_SK is
'The page request date surrogate key.';

comment on column FACT_WEB_PAGE_VIEW.REQUEST_TIME_SK is
'The time of day surrogate key.  This relates to the time dimension.';

comment on column FACT_WEB_PAGE_VIEW.GEO_LOCATION_SK is
'The geographic location surrogate key.  This relates to the geographic location dimension.';

comment on column FACT_WEB_PAGE_VIEW.REFERER_URL_SK is
'The web site referer surrogate key.  This relates to the web site referer dimension.';

comment on column FACT_WEB_PAGE_VIEW.WEB_FILE_SK is
'The web file surrogate key.  This relates to the web file dimension.';

comment on column FACT_WEB_PAGE_VIEW.WEB_VISITOR_SK is
'The web visitor surrogate key.  This relates to the web visitor dimension.';

comment on column FACT_WEB_PAGE_VIEW.WEB_BROWSER_OS_SK is
'The web browser operating system surrogate key.  This relates to the web browser operating system dimension.';

comment on column FACT_WEB_PAGE_VIEW.CUSTOMER_SK is
'The customer surrogate key.  This relates to the customer dimension.';

comment on column FACT_WEB_PAGE_VIEW.CAMPAIGN_WAVE_SK is
'The campaign wave surrogate key.  The relates to the campaign wave dimension.';

comment on column FACT_WEB_PAGE_VIEW.PRODUCT_SK is
'The product surrogate key.  This relates to the product dimension.';

comment on column FACT_WEB_PAGE_VIEW.SOURCE_SYSTEM_SK is
'The source system surrogate key.  All dimensions and base grain fact tables must include this column to enable multiple source system capabililty.';

comment on column FACT_WEB_PAGE_VIEW.WEB_FILE_BYTE_QTY is
'The web file byte quantity.';

comment on column FACT_WEB_PAGE_VIEW.WEB_PAGE_VIEW_QTY is
'The web page view quantity.';

comment on column FACT_WEB_PAGE_VIEW.ROBOT_PAGE_VIEW_QTY is
'The robot/crawler/spider view quantity.';

comment on column FACT_WEB_PAGE_VIEW.DW_LOAD_DATE is
'The date the row was inserted or update in the table.';

/*==============================================================*/
/* Index: FACT_WEB_PAGE_VIEW_LOC_BI                             */
/*==============================================================*/
create index FACT_WEB_PAGE_VIEW_LOC_BI on FACT_WEB_PAGE_VIEW (
   GEO_LOCATION_SK ASC
)
;

/*==============================================================*/
/* Table: FACT_WEB_SITE_REFERER                                 */
/*==============================================================*/
create table FACT_WEB_SITE_REFERER  (
   REFERRAL_DATE_SK     NUMBER                         default 0,
   REFERER_URL_SK       NUMBER                         default 0,
   WEB_FILE_SK          NUMBER                         default 0,
   GEO_LOCATION_SK      NUMBER                         default 0,
   WEB_VISITOR_SK       NUMBER                         default 0,
   REFERRAL_QTY         NUMBER                         default 1,
   WEB_FILE_BYTE_QTY    NUMBER                         default 0,
   WEB_PAGE_VIEW_QTY    NUMBER                         default 1,
   DW_LOAD_DATE         DATE                           default SYSDATE
);

comment on table FACT_WEB_SITE_REFERER is
'FACT_WEB_SITE_REFERER';

comment on column FACT_WEB_SITE_REFERER.REFERRAL_DATE_SK is
'The referral date surrogate key.  This column may be used to partition the fact table by time.';

comment on column FACT_WEB_SITE_REFERER.REFERER_URL_SK is
'The web site referer surrogate key.  This relates to the web site referer dimension.';

comment on column FACT_WEB_SITE_REFERER.WEB_FILE_SK is
'The web file surrogate key.  This relates to the web file dimension.';

comment on column FACT_WEB_SITE_REFERER.GEO_LOCATION_SK is
'The geographic location surrogate key.  This relates to the geographic location dimension.';

comment on column FACT_WEB_SITE_REFERER.WEB_VISITOR_SK is
'The web visitor surrogate key.  This relates to the web visitor dimension.';

comment on column FACT_WEB_SITE_REFERER.REFERRAL_QTY is
'The referral quantity.';

comment on column FACT_WEB_SITE_REFERER.WEB_FILE_BYTE_QTY is
'The web file byte quantity.';

comment on column FACT_WEB_SITE_REFERER.WEB_PAGE_VIEW_QTY is
'The web page view quantity.';

comment on column FACT_WEB_SITE_REFERER.DW_LOAD_DATE is
'The date the row was inserted or update in the table.';

/*==============================================================*/
/* Index: FACT_WEB_SITE_REF_DAY_BI                              */
/*==============================================================*/
create bitmap index FACT_WEB_SITE_REF_DAY_BI on FACT_WEB_SITE_REFERER (
   REFERRAL_DATE_SK ASC
)
;

/*==============================================================*/
/* Index: FACT_WEB_SITE_REF_LOC_BI                              */
/*==============================================================*/
create bitmap index FACT_WEB_SITE_REF_LOC_BI on FACT_WEB_SITE_REFERER (
   GEO_LOCATION_SK ASC
)
;

/*==============================================================*/
/* Index: FACT_WEB_SITE_REF_REFERER_BI                          */
/*==============================================================*/
create bitmap index FACT_WEB_SITE_REF_REFERER_BI on FACT_WEB_SITE_REFERER (
   REFERER_URL_SK ASC
)
;

/*==============================================================*/
/* Index: FACT_WEB_SITE_REF_VISITOR_BI                          */
/*==============================================================*/
create bitmap index FACT_WEB_SITE_REF_VISITOR_BI on FACT_WEB_SITE_REFERER (
   WEB_VISITOR_SK ASC
)
;

/*==============================================================*/
/* Index: FACT_WEB_SITE_REF_WEB_FILE_BI                         */
/*==============================================================*/
create bitmap index FACT_WEB_SITE_REF_WEB_FILE_BI on FACT_WEB_SITE_REFERER (
   WEB_FILE_SK ASC
);

/*==============================================================*/
/* Table: FACT_WEB_SITE_VISIT                                   */
/*==============================================================*/
create table FACT_WEB_SITE_VISIT  (
   VISIT_DATE           DATE,
   VISIT_DATE_SK        NUMBER                         default 0,
   GEO_LOCATION_SK      NUMBER                         default 0,
   WEB_VISITOR_SK       NUMBER                         default 0,
   WEB_VISIT_QTY        NUMBER                         default 1,
   WEB_FILE_BYTE_QTY    NUMBER                         default 0,
   WEB_PAGE_VIEW_QTY    NUMBER                         default 0,
   NEW_VISITOR_QTY      NUMBER                         default 0,
   RETURNING_VISITOR_QTY NUMBER                         default 0,
   ROBOT_PAGE_VIEW_QTY  NUMBER                         default 0,
   DW_LOAD_DATE         DATE                           default SYSDATE
);

comment on table FACT_WEB_SITE_VISIT is
'This fact table aggregates the web page viewing activity of a visitor at a given location to the day level.';

comment on column FACT_WEB_SITE_VISIT.VISIT_DATE is
'The visit date.  This column may be used to partition the fact table by time.';

comment on column FACT_WEB_SITE_VISIT.VISIT_DATE_SK is
'The visit date surrogate key.  This column may be used to partition the fact table by time.';

comment on column FACT_WEB_SITE_VISIT.GEO_LOCATION_SK is
'The geographic location surrogate key.  This relates to the geographic location dimension.';

comment on column FACT_WEB_SITE_VISIT.WEB_VISITOR_SK is
'The web visitor surrogate key.  This relates to the web visitor dimension.';

comment on column FACT_WEB_SITE_VISIT.WEB_VISIT_QTY is
'The web visit quantity.';

comment on column FACT_WEB_SITE_VISIT.WEB_FILE_BYTE_QTY is
'The web file byte quantity.';

comment on column FACT_WEB_SITE_VISIT.WEB_PAGE_VIEW_QTY is
'The web page view quantity.';

comment on column FACT_WEB_SITE_VISIT.NEW_VISITOR_QTY is
'The new visitor quantity.';

comment on column FACT_WEB_SITE_VISIT.RETURNING_VISITOR_QTY is
'The returning visitor quantity.';

comment on column FACT_WEB_SITE_VISIT.ROBOT_PAGE_VIEW_QTY is
'The robot/crawler/spider view quantity.';

comment on column FACT_WEB_SITE_VISIT.DW_LOAD_DATE is
'The date the row was inserted or update in the table.';

/*==============================================================*/
/* Index: FACT_WEB_SITE_VISIT_DAY_BI                            */
/*==============================================================*/
create bitmap index FACT_WEB_SITE_VISIT_DAY_BI on FACT_WEB_SITE_VISIT (
   VISIT_DATE_SK ASC
)
;

/*==============================================================*/
/* Index: FACT_WEB_SITE_VISIT_VISITOR_BI                        */
/*==============================================================*/
create bitmap index FACT_WEB_SITE_VISIT_VISITOR_BI on FACT_WEB_SITE_VISIT (
   WEB_VISITOR_SK ASC
)
;

/*==============================================================*/
/* Index: FACT_WEB_VISIT_LOC_BI                                 */
/*==============================================================*/
create bitmap index FACT_WEB_VISIT_LOC_BI on FACT_WEB_SITE_VISIT (
   GEO_LOCATION_SK ASC
;

CREATE TABLE MDW.STAGE_GEO_CITY_BLOCKS  
( LONG_IP_START_NUMBER NUMBER,  
LONG_IP_END_NUMBER NUMBER,  
GEO_LOCATION_ID NUMBER,  
DW_ERROR_IND CHAR(1 BYTE) DEFAULT 'N',  
DW_SOFT_DELETE_IND CHAR(1 BYTE) DEFAULT 'N',  
DW_LOAD_DATE DATE DEFAULT SYSDATE,  
CONSTRAINT STAGE_GEO_CITY_BLOCKS_UK UNIQUE (LONG_IP_START_NUMBER, LONG_IP_END_NUMBER, GEO_LOCATION_ID) ENABLE,  
CONSTRAINT STAGE_GEO_CITY_BLOCKS_LOC_FK FOREIGN KEY (GEO_LOCATION_ID) 
REFERENCES MDW.STAGE_GEO_CITY_LOCATION (GEO_LOCATION_ID) ENABLE 
) ; 
 
CREATE TABLE MDW.STAGE_GEO_CITY_LOCATION  
( GEO_LOCATION_ID NUMBER NOT NULL ENABLE,  
ISO_3166_COUNTRY_CODE VARCHAR2(3 BYTE),  
GEO_REGION_CODE VARCHAR2(2 BYTE),  
CITY_NAME VARCHAR2(60 BYTE),  
POSTAL_CODE VARCHAR2(32 BYTE),  
LATITUDE_NUMBER NUMBER(7,4),  
LONGITUDE_NUMBER NUMBER(7,4),  
DMA_CODE NUMBER,  
PHONE_REGION_CODE NUMBER,  
DW_ERROR_IND CHAR(1 BYTE) DEFAULT 'N',  
DW_SOFT_DELETE_IND CHAR(1 BYTE) DEFAULT 'N',  
DW_LOAD_DATE DATE DEFAULT SYSDATE,  
CONSTRAINT STAGE_GEO_CITY_LOCATION_PK PRIMARY KEY (GEO_LOCATION_ID) ENABLE 
) ; 
 
CREATE TABLE MDW.STAGE_GEO_DMA  
( DMA_CODE VARCHAR2(32 BYTE),  
DMA_NAME VARCHAR2(60 BYTE),  
DW_ERROR_IND CHAR(1 BYTE) DEFAULT 'N',  
DW_SOFT_DELETE_IND CHAR(1 BYTE) DEFAULT 'N',  
DW_LOAD_DATE DATE DEFAULT SYSDATE 
) ; 
 
CREATE TABLE MDW.STAGE_GEO_ISO_COUNTRY  
( ISO_3166_COUNTRY_CODE VARCHAR2(32 BYTE),  
ISO_3166_COUNTRY_NAME VARCHAR2(60 BYTE),  
DW_ERROR_IND CHAR(1 BYTE) DEFAULT 'N',  
DW_SOFT_DELETE_IND CHAR(1 BYTE) DEFAULT 'N',  
DW_LOAD_DATE DATE DEFAULT SYSDATE 
) ; 
 
CREATE TABLE MDW.STAGE_GEO_ISO_COUNTRY_FIPS_REG  
( ISO_3166_COUNTRY_CODE VARCHAR2(32 BYTE),  
FIPS_10_4_REGION_CODE VARCHAR2(32 BYTE),  
FIPS_10_4_REGION_NAME VARCHAR2(60 BYTE),  
DW_ERROR_IND CHAR(1 BYTE) DEFAULT 'N',  
DW_SOFT_DELETE_IND CHAR(1 BYTE) DEFAULT 'N',  
DW_LOAD_DATE DATE DEFAULT SYSDATE 
) ; 
 
CREATE TABLE MDW.STAGE_GEO_ISO_COUNTRY_ISO_REG  
( ISO_3166_COUNTRY_CODE VARCHAR2(32 BYTE),  
ISO_3166_2_REGION_CODE VARCHAR2(32 BYTE),  
ISO_3166_2_REGION_NAME VARCHAR2(60 BYTE),  
DW_ERROR_IND CHAR(1 BYTE) DEFAULT 'N',  
DW_SOFT_DELETE_IND CHAR(1 BYTE) DEFAULT 'N',  
DW_LOAD_DATE DATE DEFAULT SYSDATE 
) ; 
 
CREATE TABLE MDW.STAGE_GEO_ORGANIZATION  
( LONG_IP_START_NUMBER NUMBER,  
LONG_IP_END_NUMBER NUMBER,  
WEB_ORGANIZATION_DESC VARCHAR2(255 BYTE),  
DW_ERROR_IND CHAR(1 BYTE) DEFAULT 'N',  
DW_SOFT_DELETE_IND CHAR(1 BYTE) DEFAULT 'N',  
DW_LOAD_DATE DATE DEFAULT SYSDATE,  
CONSTRAINT STAGE_GEO_ORGANIZATION_UK UNIQUE (LONG_IP_START_NUMBER, LONG_IP_END_NUMBER, WEB_ORGANIZATION_DESC) ENABLE 
) ; 
 
 
/*==============================================================*/
/* Table: STAGE_WEB_REQUEST                              */
/*==============================================================*/
create table STAGE_WEB_REQUEST  (
   REQUEST_DATE         DATE,
   WEB_VISITOR_LOGIN_NAME VARCHAR2(60),
   WEB_VISITOR_FULL_NAME VARCHAR2(60),
   WEB_FILE_NAME        VARCHAR2(2000),
   REQUEST_CAT          VARCHAR2(32),
   HTTP_VERSION_NAME    VARCHAR2(60),
   SERVER_STATUS_CODE   VARCHAR2(32),
   WEB_FILE_BYTE_QTY    NUMBER                         default 0,
   REFERER_URL_DESC     VARCHAR2(2000),
   WEB_BROWSER_OS_DESC  VARCHAR2(2000),
   GMT_OFFSET_CAT       VARCHAR2(32),
   REQUEST_DATE_SK      NUMBER,
   REQUEST_TIME_ID      VARCHAR2(32),
   LONG_IP_NUMBER       NUMBER,
   IP_ADDRESS_DESC      VARCHAR2(2000),
   MINUTE_QTY           NUMBER(2),
   HOUR_24_QTY          NUMBER(2),
   ROBOT_PAGE_VIEW_QTY  NUMBER                         default 0,
   SOURCE_SYSTEM_ID     VARCHAR2(32)                   default '1',
   DW_ERROR_IND         CHAR                           default 'N',
   DW_SOFT_DELETE_IND   CHAR                           default 'N',
   DW_LOAD_DATE         DATE                           default SYSDATE
);

comment on table STAGE_WEB_REQUEST is
'The web server request stage table.  This table maintains relatively raw data from the web server log.';

comment on column STAGE_WEB_REQUEST.REQUEST_DATE is
'The web page request date.';

comment on column STAGE_WEB_REQUEST.WEB_VISITOR_LOGIN_NAME is
'The web visitor login name (rarely used).';

comment on column STAGE_WEB_REQUEST.WEB_VISITOR_FULL_NAME is
'The web visitor full name (rarely used).';

comment on column STAGE_WEB_REQUEST.WEB_FILE_NAME is
'The web file name (e.g., /etl_maps.html).';

comment on column STAGE_WEB_REQUEST.REQUEST_CAT is
'The web server request type (e.g., GET).';

comment on column STAGE_WEB_REQUEST.HTTP_VERSION_NAME is
'The HTTP version name, e.g., HTTP/1.1.';

comment on column STAGE_WEB_REQUEST.SERVER_STATUS_CODE is
'The web server status code, e.g., 404, 401, 200, 304, etc.';

comment on column STAGE_WEB_REQUEST.WEB_FILE_BYTE_QTY is
'The web file byte quantity.';

comment on column STAGE_WEB_REQUEST.REFERER_URL_DESC is
'The referer URL description.';

comment on column STAGE_WEB_REQUEST.WEB_BROWSER_OS_DESC is
'The web browser operating system description.';

comment on column STAGE_WEB_REQUEST.GMT_OFFSET_CAT is
'The GMT offset category, e.g., -0700.';

comment on column STAGE_WEB_REQUEST.REQUEST_DATE_SK is
'The page request date surrogate key, fomat YYYYMMDD.';

comment on column STAGE_WEB_REQUEST.REQUEST_TIME_ID is
'The web server request time identifier - format HH24MI, e.g., 2109.';

comment on column STAGE_WEB_REQUEST.LONG_IP_NUMBER is
'The long IP address.';

comment on column STAGE_WEB_REQUEST.IP_ADDRESS_DESC is
'The IP address description, e.g., 192.168.0.100.';

comment on column STAGE_WEB_REQUEST.MINUTE_QTY is
'The minute value from the request time.';

comment on column STAGE_WEB_REQUEST.HOUR_24_QTY is
'The hour value from the request time.';

comment on column STAGE_WEB_REQUEST.ROBOT_PAGE_VIEW_QTY is
'The robot/crawler/spider view quantity.';

comment on column STAGE_WEB_REQUEST.SOURCE_SYSTEM_ID is
'The source system identifier.  All dimensions and base grain fact tables must include this column to enable multiple source system capabililty.';

comment on column STAGE_WEB_REQUEST.DW_ERROR_IND is
'This denotes if a particular row in the staging table has failed a previous load attempt.';

comment on column STAGE_WEB_REQUEST.DW_SOFT_DELETE_IND is
'This denotes that a row in the stage table has been soft-deleted.  Soft deleted have been sucessfully loaded into the data warehouse.';

comment on column STAGE_WEB_REQUEST.DW_LOAD_DATE is
'The date the row was inserted or updated into the data warehouse table.';

/*==============================================================*/
/* Index: STG_WEB_SERVER_REQUEST_IDX                            */
/*==============================================================*/
create index STG_WEB_SERVER_REQUEST_IDX on STAGE_WEB_REQUEST (
   LONG_IP_NUMBER ASC
);


--Good for development, but disable and set to rely for production if performance requires.

alter table DIMENSION_WEB_VISITOR
   add constraint DIM_WEB_VISITOR_BROW_OS_FK foreign key (WEB_VISITOR_SK)
      references DIMENSION_WEB_BROWSER_OS (WEB_BROWSER_OS_SK)
      not deferrable;

alter table FACT_WEB_PAGE_VIEW
   add constraint FACT_WEB_PAGE_FILE_FK foreign key (WEB_FILE_SK)
      references DIMENSION_WEB_FILE (WEB_FILE_SK)
      not deferrable;

alter table FACT_WEB_PAGE_VIEW
   add constraint FACT_WEB_PAGE_VIEW_BROW_OS_FK foreign key (WEB_BROWSER_OS_SK)
      references DIMENSION_WEB_BROWSER_OS (WEB_BROWSER_OS_SK)
      not deferrable;

alter table FACT_WEB_PAGE_VIEW
   add constraint FACT_WEB_PAGE_VIEW_DAY_FK foreign key (REQUEST_DATE_SK)
      references DIMENSION_DAY (DATE_SK)
      not deferrable;

alter table FACT_WEB_PAGE_VIEW
   add constraint FACT_WEB_PAGE_VIEW_GEO_LOC_FK foreign key (GEO_LOCATION_SK)
      references DIMENSION_GEOGRAPHIC_LOCATION (GEO_LOCATION_SK)
      not deferrable;

alter table FACT_WEB_PAGE_VIEW
   add constraint FACT_WEB_PAGE_VIEW_REFERER_FK foreign key (REFERER_URL_SK)
      references DIMENSION_WEB_SITE_REFERER (REFERER_URL_SK)
      not deferrable;

alter table FACT_WEB_PAGE_VIEW
   add constraint FACT_WEB_PAGE_VISITOR_FK foreign key (WEB_VISITOR_SK)
      references DIMENSION_WEB_VISITOR (WEB_VISITOR_SK)
      not deferrable;

alter table FACT_WEB_PAGE_VIEW
   add CONSTRAINT FACT_WEB_PAGE_VIEW_TIME_FK FOREIGN KEY (REQUEST_TIME_SK)
      REFERENCES MDW.DIMENSION_TIME (TIME_SK)
      not deferrable;

alter table FACT_WEB_SITE_REFERER
   add constraint FACT_WEB_SITE_REF_DATE_FK foreign key (REFERRAL_DATE_SK)
      references DIMENSION_DAY (DATE_SK)
      not deferrable;

alter table FACT_WEB_SITE_REFERER
   add constraint FACT_WEB_SITE_REF_GEO_LOC_FK foreign key (GEO_LOCATION_SK)
      references DIMENSION_GEOGRAPHIC_LOCATION (GEO_LOCATION_SK)
      not deferrable;

alter table FACT_WEB_SITE_REFERER
   add constraint FACT_WEB_SITE_REF_REFERER_FK foreign key (REFERER_URL_SK)
      references DIMENSION_WEB_SITE_REFERER (REFERER_URL_SK)
      not deferrable;

alter table FACT_WEB_SITE_REFERER
   add constraint FACT_WEB_SITE_REF_VISITOR_FK foreign key (WEB_VISITOR_SK)
      references DIMENSION_WEB_VISITOR (WEB_VISITOR_SK)
      not deferrable;

alter table FACT_WEB_SITE_REFERER
   add constraint FACT_WEB_SITE_REF_WEB_FILE_FK foreign key (WEB_FILE_SK)
      references DIMENSION_WEB_FILE (WEB_FILE_SK)
      not deferrable;

alter table FACT_WEB_SITE_VISIT
   add constraint FACT_WEB_SITE_VISIT_DATE_FK foreign key (VISIT_DATE_SK)
      references DIMENSION_DAY (DATE_SK)
      not deferrable;

alter table FACT_WEB_SITE_VISIT
   add constraint FACT_WEB_SITE_VISIT_GEO_LOC_FK foreign key (GEO_LOCATION_SK)
      references DIMENSION_GEOGRAPHIC_LOCATION (GEO_LOCATION_SK)
      not deferrable;

alter table FACT_WEB_SITE_VISIT
   add constraint FACT_WEB_SITE_VISIT_VISITOR_FK foreign key (WEB_VISITOR_SK)
      references DIMENSION_WEB_VISITOR (WEB_VISITOR_SK)
      not deferrable;

