# breadboard
These analytic modules - helping companies in Australia, Europe, and North America - have been made available as-is to kickstart an update and expansion effort in the community. Configuration and use requires Pentaho and database developer skills.  Porting to other ETL and/or BI tools should be easy.

Database
=========
The enterprise, dimensional, multi-tenant data model is currently stored in a Toad Data Modeler file, it is also now available as a DDL file for MySQL and Snowflake.  Use the data model file to build for other RDBMS systems.  While designed many years ago, this model is still relevant to current data warehouse / data mart projects.

The data model was created on a old version of Toad Data Modeler. You can get a copy of the freeware here: http://www.toadworld.com/m/freeware/553.  The freeware version has limitations that will affect your ability to work with the model.  Developers that actively participate in updating and expanding content will be granted access to a MySQL version of the database with test data.

ETL
===
While the ETL was created on Pentaho Data Integration (PDI) version 2.5.2 - it should work with newer versions, and the process of updating the objects will be somewhat less painful than the BI server objects (see below).  This section also includes table input steps with SQL designed to help extract data from some Compiere, JDE, PeopleSoft, and SugarCRM tables.  New objects, best practices, etc. will need to be introduced over time.

The ETL transformation logic is not complex, so porting it to Talend, Informatica, or another tool should be easy.  Likewise, moving the logic to an ELT tool/scripts should also be easy.

BI Server
==========
Many of the cubes, dashboards, and reports were originally created using Pentaho BA Server 1.2, however the content is currently being updated to BA Server 6.  The last version that the old content was known to work on was 4.8.1.  Old versions of Pentaho BA server are available on SourceForge - http://sourceforge.net/projects/pentaho/files/.

Since the underlying data model is dimensional, building presentation layer objects over other tools like Tableau, Looker, etc. is very easy.
