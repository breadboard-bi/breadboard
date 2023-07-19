{\rtf1\ansi\ansicpg1252\cocoartf2709
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 \'97Helpful DML commands\
\
--Clear all between tests\
truncate table stage_order_type;\
truncate table dimension_order_type;\
create or replace stream stage_order_type_changes on table stage_order_type; -- stream nation_table_changes\
\
--SEED TEST DATA    \
set update_timestamp = current_timestamp()::timestamp_ntz;\
begin;\
insert into stage_order_type (order_type_id, source_system_id, order_type_name, order_type_desc,hosted_client_sk, dw_error_ind,dw_soft_delete_ind, dw_load_date)\
values('1',1,'Order Type Name 1','Order Type Desc 1',1,'N','N',$update_timestamp);\
\
insert into stage_order_type (order_type_id, source_system_id, order_type_name, order_type_desc,hosted_client_sk, dw_error_ind,dw_soft_delete_ind, dw_load_date)\
values('2',1,'Order Type Name 2','Order Type Desc 2',1,'N','N',$update_timestamp);\
\
insert into stage_order_type (order_type_id, source_system_id, order_type_name, order_type_desc,hosted_client_sk, dw_error_ind,dw_soft_delete_ind, dw_load_date)\
values('3',1,'Order Type Name 3','Order Type Desc 3',1,'N','N',$update_timestamp);\
\
insert into stage_order_type (order_type_id, source_system_id, order_type_name, order_type_desc,hosted_client_sk, dw_error_ind,dw_soft_delete_ind, dw_load_date)\
values('4',1,'Order Type Name 4','Order Type Desc 4',1,'N','N',$update_timestamp);\
\
insert into stage_order_type (order_type_id, source_system_id, order_type_name, order_type_desc,hosted_client_sk, dw_error_ind,dw_soft_delete_ind, dw_load_date)\
values('5',1,'Order Type Name 5','Order Type Desc 5',1,'N','N',$update_timestamp);\
\
insert into stage_order_type (order_type_id, source_system_id, order_type_name, order_type_desc,hosted_client_sk, dw_error_ind,dw_soft_delete_ind, dw_load_date)\
values('6',1,'Order Type Name 6','Order Type Desc 6',1,'N','N',$update_timestamp);\
commit;\
\
insert into stage_order_type (order_type_id, source_system_id, order_type_name, order_type_desc,hosted_client_sk, dw_error_ind,dw_soft_delete_ind, dw_load_date)\
values('7',1,'Order Type Name 7','Order Type Desc 7',1,'N','N',$update_timestamp);\
commit;\
\
insert into stage_order_type (order_type_id, source_system_id, order_type_name, order_type_desc,hosted_client_sk, dw_error_ind,dw_soft_delete_ind, dw_load_date)\
values('8',1,'Order Type Name 8','Order Type Desc 8',1,'N','N',$update_timestamp);\
commit;\
\
insert into stage_order_type (order_type_id, source_system_id, order_type_name, order_type_desc,hosted_client_sk, dw_error_ind,dw_soft_delete_ind, dw_load_date)\
values('9',1,'Order Type Name 9','Order Type Desc 9',1,'N','N',$update_timestamp);\
commit;\
\
\
--TEST DML\
show streams;\
select * from stage_order_type_changes; --query stream\
select * from order_type_change_data; --query view\
\
show tasks;\
\
--Check when task will next run.\
select timestampdiff(second, current_timestamp, scheduled_time) as next_run, scheduled_time, current_timestamp, name, \
state \
from table(information_schema.task_history()) \
where state = 'SCHEDULED' and name = 'POPULATE_DIMENSION_ORDER_TYPE'\
order by completed_time desc;\
\
select * from dimension_order_type;\
select * from stage_order_type;\
\
--Test several logic paths\
update stage_order_type set order_type_name = 'OT 5++', dw_load_date = current_timestamp() where order_type_id = '5';\
delete from stage_order_type where order_type_id = 4;\
update stage_order_type set dw_soft_delete_ind = 'Y' where order_type_id = 3;\
update stage_order_type set hosted_client_sk = 125, dw_load_date = current_timestamp() where order_type_id ='2';\
delete from dimension_order_type where order_type_id = 3}