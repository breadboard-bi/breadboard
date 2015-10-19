#!/bin/bash

DBHOST='localhost'
DBUSER='root'
DBPASSWD='root'
LOCALDIR=/mnt/mysql/backup/
ARCHIVEDIR=/mnt/mysql/backup/archive/
GDCDIR=/mnt/mysql/gdc/

# S3 related variables
GDC_AWS_ID=a382d287d4d58222758ddeb5c760fd18842e69b8b1904cfe99c2c503f70e6f5b
BB_AWS_ID=e6146eae1b8e9afdca9b0f5197c1864dba8937fe6c1946e68ec6ce253771c40a
AWS_ACCESS_KEY=16MC6XVHAG77MZ130B82
AWS_SECURE_KEY=qDObVy1wnDwLGX6nh2i3GuCte/Y8sVsCIB3+Agr8

mv $LOCALDIR/*.gz $ARCHIVEDIR/

# Using the date function's --date="last week" to delete backups that are 7 days old 
OLDSUFFIX=`date --date="last week" +%Y%m%d`
SUFFIX=`date +%Y%m%d`
DBS=`mysql -u$DBUSER -p$DBPASSWD -h$DBHOST -e"show databases"`
su_cmd=""
for DATABASE in $DBS; do
if [ $DATABASE = "mdw" ]; then
   OLDFILENAME=$OLDSUFFIX-$DATABASE.sql
   FILENAME=$SUFFIX-$DATABASE.sql
   su_cmd="${su_cmd} rm -f $ARCHIVEDIR$OLDFILENAME.gz;"
   mysqldump -u$DBUSER -p$DBPASSWD -h$DBHOST $DATABASE --compatible=mysql40 | gzip > $LOCALDIR$FILENAME.gz

    cp  $LOCALDIR$FILENAME.gz $GDCDIR$FILENAME.gz

 fi
done
su -c "${su_cmd}"

# use s3sync to push the latest mysql backup to the breadboardbi-gdc S3 bucket, and all backups to breadboard-mysql bucket.
cd /usr/local/s3sync/
ruby s3sync.rb -r -s -v --delete /$LOCALDIR/ breadboardbi-mysql: > /var/log/s3sync_mysql
ruby s3sync.rb -s -v /$GDCDIR/ breadboardbi-gdc: > /var/log/s3sync_gdc

# set ACLs.
cd /usr/local/etl/scripts/
python setS3acl.py -a 16MC6XVHAG77MZ130B82 -s qDObVy1wnDwLGX6nh2i3GuCte/Y8sVsCIB3+Agr8 -b "breadboardbi-gdc" -f $FILENAME.gz -o e6146eae1b8e9afdca9b0f5197c1864dba8937fe6c1946e68ec6ce253771c40a "a382d287d4d58222758ddeb5c760fd18842e69b8b1904cfe99c2c503f70e6f5b:FULL_CONTROL" "e6146eae1b8e9afdca9b0f5197c1864dba8937fe6c1946e68ec6ce253771c40a:FULL_CONTROL"

# remove GD copy of file.
rm $GDCDIR* 

echo "done";
