#!/bin/bash

# syn_group on this script we while use 2 groups that are using differents direction
top_admin="admin"
#nextcloud_path="/data/nextclouduzunov/app/data"
nextcloud_path="/data/nextcloud/app/data"
#external_cloud_path_base="dropbox:/Uzunov Consulting/0 Novi Dokumenti"
external_cloud_path_base="dropneeds:/test/Novi Dokumenti"
#container_name="nextclouduzunov_app_1"
container_name="nextcloud_app_1"

while [ 1 ]
do
  for group in '.customerpm[]' '.customerpp[]' ; do
    list=`docker exec -u 33 ${container_name} ./occ  group:list --output=json | jq -r $group -c`
    # echo $group
    for user in $list ; do
      display_name=`docker exec -u 33 ${container_name} ./occ user:info ${user} --output=json | jq -r .display_name`
      user_out_dir="${nextcloud_path}/${user}/files/UPLOAD/"
      user_in_dir="${nextcloud_path}/${user}/files/DOWNLOAD/"
      # echo $user
      if [ $group = '.customerpp[]' ]; then
        customer_group_path="Customer_PP"
        admin_in_dir="${nextcloud_path}/${top_admin}/files/${customer_group_path}/${display_name}/receive/"
        admin_out_dir="${nextcloud_path}/${top_admin}/files/${customer_group_path}/${display_name}/send/"
        external_cloud_path="${external_cloud_path_base}/${display_name}/"
      fi
      if [ $group = '.customerpm[]' ]; then
        customer_group_path="Customer_PM"
        admin_in_dir="${nextcloud_path}/${top_admin}/files/${customer_group_path}/${display_name}/receive/"
        admin_out_dir="${nextcloud_path}/${top_admin}/files/${customer_group_path}/${display_name}/send/"
        full_name=""
        this_year=`date +%Y`
        declaration_year=`expr $this_year - 1`
        external_cloud_path="${external_cloud_path_base}/0 Déclarations à faire/déclarations PM ${declaration_year}/${display_name}/"
      fi
      if [ ! -d "${user_out_dir}" ]; then
        sudo -u www-data mkdir -p "${user_out_dir}"
      fi
      if [ ! -d "${user_in_dir}" ]; then
        sudo -u www-data mkdir -p "${user_in_dir}"
      fi
      if [ ! -d "${admin_in_dir}" ]; then
        sudo -u www-data mkdir -p "${admin_in_dir}"
      fi
      if [ ! -d "${admin_out_dir}" ]; then
        sudo -u www-data mkdir -p "${admin_out_dir}"
      fi

      ## From customer to admin ##
      ACT=""
      ## test if there is a new file in the UPLOAD folder of our customers
      NEW_FILE=`find ${user_out_dir} -type f ! -iname '*.part' ! -iname '*.md'`
      if [ "$NEW_FILE" != "" ] ; then
        # echo $NEW_FILE
        sudo -u www-data rsync -arc --exclude '*.part'  "${user_out_dir}" "${admin_in_dir}"
        # dropbox folder creation and rsync of files to dropbox
        rclone mkdir "${external_cloud_path}"
        rclone copy "${user_out_dir}" "${external_cloud_path}"
        rclone copy  --exclude '*.md' --exclude '*.part' "${user_out_dir}" "${dropbox_path}"
        sudo -u www-data find ${user_out_dir}/ -type f ! -iname '*.part' -exec rm {} \;
        # sudo -u www-data find ${user_out_dir}/* -type d ! -iname '*.part' -exec rmdir {} \;
        ACT=1
      fi
      # From Admin to customer
      # compare send et DOWNOAD
      DIR_DIFF=`diff -qr "${admin_out_dir}" "${user_in_dir}"`
      if [ "$DIR_DIFF" != "" ] ; then
        # echo $DIR_DIFF
        sudo -u www-data rsync -arc --delete --exclude '*.part' "${admin_out_dir}" "${user_in_dir}"
        ACT=1
      fi
      # dropbox folder creation and rsync of files to dropbox
      # rclone mkdir "${dropbox_path}"
      # rclone copy "${admin_in_dir}" "${dropbox_path}"
      # Next version we need to test if new files were copy to run files:scan
      # Check if there is some differences and run ...
      if [ "$ACT" = 1 ] ; then
        # echo "Lets run"
        docker exec -u 33 ${container_name} ./occ files:scan -p "${user}/files/UPLOAD"
        docker exec -u 33 ${container_name} ./occ files:scan -p "${user}/files/DOWNLOAD"
        docker exec -u 33 ${container_name} ./occ files:scan -p "admin/files/${customer_group_path}/${display_name}"
      fi
    done
  done
  sleep 25
done
