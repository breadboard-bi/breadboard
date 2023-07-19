{\rtf1\ansi\ansicpg1252\cocoartf2709
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 /* \
Initial pattern to load an MDW dimension from a stage table using Slowly Changing Dimension (SCD2) logic on Snowflake.\
\
This script builds a sequence, stream, view, and task.  A Snowflake warehouse is also required, as well as the appropriate privileges.\
\
The core logic is based on an article written by John Gontarz, Sales Engineer at Snowflake - https://community.snowflake.com/s/article/Building-a-Type-2-Slowly-Changing-Dimension-in-Snowflake-Using-Streams-and-Tasks-Part-1.  \
\
Modifications made to work with the existing MDW enterprise dimensional model and to limit which columns trigger SCD2 insert/update versus a regular update.\
\
Assumes the stage_order_type and dimension_order_type MDW tables have already been built. See mdw_master_snowflake.txt for the DDL.\
*/\
\
create or replace sequence SEQ_ORDER_TYPE start with 1 increment by 1;\
\
create or replace stream stage_order_type_changes on table stage_order_type;\
\
--generates data to load into the dimension_order_type table.\
create or replace view order_type_change_data as\
-- This first subquery figures out what to do when data is inserted into the stage_order_type table\
-- An insert to the stage_order_type table results in an INSERT to the dimension_order_type table\
select order_type_sk, order_type_id, order_type_name, order_type_desc, source_system_sk, \
hosted_client_sk, dw_start_date, dw_stop_date, dw_current_ind, 'I' as dml_type\
from (select order_type_sk, order_type_id, order_type_name, order_type_desc, source_system_sk, \
hosted_client_sk, dw_load_date as dw_start_date,\
lag(dw_load_date) over (partition by order_type_id order by dw_load_date desc) as dw_stop_date_raw, \
--Lag accesses dimension versions with the same key without having to join the table to itself.\
--if multiple rows with same key are found, the latest is marked as current, the rest are loaded as not current.\
case when dw_stop_date_raw is null then '9999-12-31'::timestamp_ntz else dw_stop_date_raw end as dw_stop_date,\
--case when dw_stop_date is null then 'Y' else 'N' end as dw_current_ind\
case when dw_stop_date = '9999-12-31'::timestamp_ntz then 'Y' else 'N' end as dw_current_ind\
from (select null as order_type_sk, --subsequent merge will insert SEQ_ORDER_TYPE.nextval.  This keeps the column count in the union consistent with other subqueries that need to sk.\
order_type_id, order_type_name, order_type_desc, source_system_id as source_system_sk, hosted_client_sk, dw_load_date\
    from stage_order_type_changes --stream on stage_order_type\
    where metadata$action = 'INSERT'\
    and metadata$isupdate = 'FALSE'))\
--End INSERT subquery\
union\
-- START SCD2 Update LOGIC\
-- This subquery figures out what to do when SCD2 trigger columns are updated in the stage_order_type table\
-- An update to one or more trigger columns in the stage_order_type table results in an update AND an insert to the\
-- dimension_order_type table\
-- The subquery below generates two records, each with a different dml_type\
select order_type_sk, order_type_id, order_type_name, order_type_desc, source_system_sk, hosted_client_sk, dw_start_date, dw_stop_date, dw_current_ind, dml_type\
from (select order_type_sk, order_type_id, order_type_name, order_type_desc, source_system_sk, hosted_client_sk, \
    dw_start_date as dw_start_date,  --was dw_load_date\
    lag(dw_load_date) over (partition by order_type_id order by dw_load_date desc) as dw_stop_date_raw,\
    case when dw_stop_date_raw is null then '9999-12-31'::timestamp_ntz else dw_stop_date_raw end as dw_stop_date,\
    case when dw_stop_date_raw is null then 'Y' else 'N' end as dw_current_ind,\
    dml_type\
    from (-- Identify data to insert into dimension_order_type table\
        select null as order_type_sk, --was c.\
        c.order_type_id, c.order_type_name, c.order_type_desc, c.source_system_id as source_system_sk,\
        c.hosted_client_sk, c.dw_load_date as dw_start_date, --deliberate otherwise will match and not insert.\
        c.dw_load_date, 'I' as dml_type\
        from stage_order_type_changes c --stream\
        join dimension_order_type d \
        on c.order_type_id = d.order_type_id \
        -- SCD2 trigger columns identified below are order_type_name and order_type_desc. Changes to other columns will be\
        -- excluded and handled in the update section.\
        and (d.order_type_name <> c.order_type_name or d.order_type_desc <> c.order_type_desc)\
        where c.metadata$action = 'INSERT'\
        and c.metadata$isupdate = 'TRUE'\
        and d.dw_current_ind = 'Y'\
        union\
        -- Identify data in dimension_order_type table that needs to be updated, i.e., given a stop date.\
        select order_type_sk, order_type_id, null, null, source_system_sk, null, dw_start_date, dw_load_date,\
        'U' as dml_type\
        from dimension_order_type\
        where order_type_sk in (select distinct d.order_type_sk\
                                from stage_order_type_changes c --stream\
                                --ADDED JOIN TO DIM HERE THAT includes triggers are not equal\
                                join dimension_order_type d \
                                on c.order_type_id = d.order_type_id \
                                and c.source_system_id = d.source_system_sk\
                                and (d.order_type_name <> c.order_type_name or d.order_type_desc <> c.order_type_desc)\
                                where c.metadata$action = 'INSERT'\
                                and c.metadata$isupdate = 'TRUE')\
                                and dw_current_ind = 'Y' --??\
                                ))\
-- END SCD2 logic.    \
-- START NON SCD2 UPDATES - changes in stage that do not trigger a new insert in the dimension\
union\
select order_type_sk, order_type_id, order_type_name, order_type_desc, source_system_sk, hosted_client_sk, dw_start_date, dw_stop_date, dw_current_ind, dml_type\
from (select order_type_sk, order_type_id, order_type_name, order_type_desc, source_system_sk, hosted_client_sk, \
    dw_start_date as dw_start_date, --was dw_load_date\
    lag(dw_load_date) over (partition by order_type_id order by dw_load_date desc) as dw_stop_date_raw,\
    case when dw_stop_date_raw is null then '9999-12-31'::timestamp_ntz else dw_stop_date_raw end as dw_stop_date,\
    case when dw_stop_date_raw is null then 'Y' else 'N' end as dw_current_ind,\
    dml_type\
    from (-- Identify data to insert into dimension_order_type table\
        select distinct d.order_type_sk, --was c.\
        c.order_type_id, c.order_type_name, c.order_type_desc, c.source_system_id as\
        source_system_sk, c.hosted_client_sk, d.dw_start_date, c.dw_load_date, 'UPDATE' as dml_type\
        from stage_order_type_changes c --stream\
        join dimension_order_type d \
        on c.order_type_id = d.order_type_id \
        and d.order_type_name = c.order_type_name and d.order_type_desc = c.order_type_desc\
        and c.dw_soft_delete_ind = 'N' --excludes soft delete updates (processed in delete section)\
        where c.metadata$action = 'INSERT'\
        and c.metadata$isupdate = 'TRUE'\
                                ))\
--END NON-SCD2 UPDATES\
union\
-- This subquery figures out what to do when data is deleted from the stage_order_type table (hard or soft)\
-- A deletion from the stage_order_type table results in an update to the dimension_order_type table\
select order_type_sk, order_type_id, order_type_name, order_type_desc, source_system_sk, hosted_client_sk, dw_start_date, dw_stop_date, dw_current_ind, dml_type \
from (\
select nh.order_type_sk,\
nms.order_type_id, null as order_type_name, null as order_type_desc, nms.source_system_id as\
source_system_sk, null as hosted_client_sk, nh.dw_start_date, current_timestamp()::timestamp_ntz as dw_stop_date, null as dw_current_ind, 'D' as dml_type\
from dimension_order_type nh\
inner join stage_order_type_changes nms\
on nh.order_type_id = nms.order_type_id\
where ((nms.metadata$action = 'DELETE' and nms.metadata$isupdate = 'FALSE') OR (nms.metadata$action = 'INSERT' AND nms.dw_soft_delete_ind = 'Y'))\
and nh.dw_current_ind = 'Y'\
order by nms.dw_load_date);\
--END VIEW DDL\
\
--Set up TASKADMIN role\
use role securityadmin;\
create role taskadmin;\
-- Set the active role to ACCOUNTADMIN before granting the EXECUTE TASK privilege to TASKADMIN\
use role accountadmin;\
grant execute task on account to role taskadmin;\
\
-- Set the active role to SECURITYADMIN to show that this role can grant a role to another role \
use role securityadmin;\
grant role taskadmin to role mdw_db_admin;\
\
--Tasks require a warehouse to run, so let\'92s create a task warehouse if one doesn\'92t exist:\
create warehouse if not exists mdw_wh with warehouse_size = 'XSMALL' auto_suspend = 120;\
\
--Create Task\
create or replace task populate_dimension_order_type warehouse = mdw_wh schedule = '1 minute' when system$stream_has_data('stage_order_type_changes')\
as \
--START MERGE\
merge into DIMENSION_ORDER_TYPE nh --Target table to merge changes from STAGE_ORDER_TYPE into\
using order_type_change_data m --view\
-- The order_type_change_data view holds the logic that determines what to insert/update into the DIMENSION_ORDER_TYPE table.\
   on nh.order_type_id = m.order_type_id \
   -- and nh.source_system_sk = m.source_system_sk\
   -- order_type_id & source_system_sk columns determine if there is a unique record in the DIMENSION_ORDER_TYPE table\
   and nh.dw_start_date = m.dw_start_date\
   and nh.dw_current_ind = 'Y' --only update current rows (needed?)\
when matched and m.dml_type = 'U' --SCD2 "Update"\
then update -- Indicates the original record has been updated and is no longer current and the end_time needs to be stamped\
    set nh.dw_stop_date = m.dw_stop_date,\
        nh.dw_current_ind = 'N'    \
when matched and m.dml_type = 'D' \
then update -- Deletes are essentially logical deletes. The record is stamped and no newer version is inserted\
    set nh.dw_stop_date = m.dw_stop_date,\
        nh.dw_current_ind = 'N'\
--New for non-SCD2 UPDATE\
when matched and m.dml_type = 'UPDATE' and nh.dw_current_ind = 'Y'\
then update\
set nh.hosted_client_sk = m.hosted_client_sk, --only non-SCD2 column in this small dimension.\
nh.dw_load_date = current_timestamp()\
--End UPDATE\
when not matched and m.dml_type = 'I' then insert -- Inserting a new order_type_id and updating an existing one both result in an insert\
(order_type_sk, order_type_id, order_type_name, order_type_desc, source_system_sk, hosted_client_sk, dw_start_date, dw_stop_date, dw_current_ind)\
values (SEQ_ORDER_TYPE.nextval, m.order_type_id, m.order_type_name, m.order_type_desc, m.source_system_sk, m.hosted_client_sk, m.dw_start_date, m.dw_stop_date, m.dw_current_ind);\
-- END MERGE\
--END TASK\
\
--Schedule Task\
alter task populate_dimension_order_type resume;\
show tasks;\
\
-- Suspend the task (as needed)\
--alter task populate_dimension_order_type suspend;}