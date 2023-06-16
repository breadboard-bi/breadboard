#!/bin/bash

cd ${file_path}

mysql -u root -proot -D mdw < ${file_path}mysql_infile_script.sql

# cp /tmp/mysql_infile_script.sql ${file_path}

exit
