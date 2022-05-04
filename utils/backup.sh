#!/bin/bash

sudo -u needsone docker exec nextcloud_db_1 mysqldump -u nextcloud -pDB_PASS > ./db_nextcloud.sql
rclone -L copy /etc nextpool:default/etc
rclone -L copy ./db_nextcloud.sql nextpool:default/nextcloud/
rclone -L sync /data/nextcloud nextpool:default/nextcloud
