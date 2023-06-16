#! /bin/bash
# /root/.profile
cd /usr/local/K*
nohup sh kitchen.sh -file=/usr/local/etl/JOB_EC2_WEB_SITE_VISIT.kjb -level=Minimal> /usr/local/etl/logs/JOB_EC2_WEB_SITE_VISIT.log &
