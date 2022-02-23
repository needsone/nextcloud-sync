#!/bin/bash

top_admin="admin"
nextcloud_path="/folder_with_nextcloud/app/data"
external_cloud_path_base="dropbox:/folder/p/"
container_name="nextcloud_app"

while [ 1 ]
do
 for user in `docker exec -u 33 ${container_name} ./occ  group:list --output=json | jq -r .customer[] -c` ; do
  display_name=`docker exec -u 33 ${container_name} ./occ user:info ${user} --output=json | jq -r .display_name`
  user_out_dir="${nextcloud_path}/${user}/files/UPLOAD/"
  user_in_dir="${nextcloud_path}/${user}/files/DOWNLOAD/"
  admin_in_dir="${nextcloud_path}/${top_admin}/files/Customer/${display_name}/receive/"
  admin_out_dir="${nextcloud_path}/${top_admin}/files/Customer/${display_name}/send/"
  # the rclone.conf file string muest be your cloud destination
  dropbox_path="${external_cloud_path_base}/${display_name}/"
  if [ ! -d "${user_out_dir}" ]; then
   sudo -u www-data mkdir -p "${user_out_dir}"
  fi
  if [ ! -d "${user_in_dir}" ]; then
   sudo -u www-data mkdir -p "${user_in_dir}"
  fi
  if [ ! -d "${admin_diar}" ]; then
   sudo -u www-data mkdir -p "${admin_in_dir}"
  fi
  if [ ! -d "${admin_dir}" ]; then
   sudo -u www-data mkdir -p "${admin_out_dir}"
  fi

  # From customer to admin
  sudo -u www-data rsync -arc "${user_out_dir}" "${admin_in_dir}"
  sudo -u www-data find ${user_out_dir}/ -type f ! -iname '*.part' -mmin +21 -exec rm {} \;
  # We remove only files
  sudo -u www-data find find ${user_out_dir}/* -mmin +20 -exec rm {} \; 
  # rm -rf ${user_out_dir}/

  # From Admin to customer
  sudo -u www-data rsync -arc --delete --exclude '*.md' --exclude '*.part' "${admin_out_dir}" "${user_in_dir}"

  # dropbox folder creation and rsync of files to dropbox
  rclone mkdir "${dropbox_path}"
  rclone copy "${admin_in_dir}" "\"${dropbox_path}\""

  # Next versiob we need to test if new files were copy to run files:scan

  docker exec -u 33 ${container_name} ./occ files:scan -n ${user}
  done
docker exec -u 33 ${container_name} ./occ files:scan -n ${top_admin}
#echo "Let's sleep a bit"dd
sleep 20
done
