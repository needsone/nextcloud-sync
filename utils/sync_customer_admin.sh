#!/bin/bash

top_admin="admin"
nextcloud_path="/data/nextclouduzunov/app/data/"
# external_cloud_path_base="dropbox:/Uzunov Consulting/0 Novi Dokumenti/"

while [ 1 ]
do
	for user in `docker exec -u 33 nextclouduzunov_app_1 ./occ  group:list --output=json | jq -r .customer[] -c` ; do
	    display_name=`docker exec -u 33 nextclouduzunov_app_1 ./occ user:info ${user} --output=json | jq -r .display_name`

	    user_out_dir="${nextcloud_path}/${user}/files/UPLOAD/"
			user_in_dir="${nextcloud_path}/${user}/files/DOWNLOAD/"
	    admin_in_dir="${nextcloud_path}/${top_admin}/files/Customer/${display_name}/receive/"
			admin_out_dir="${nextcloud_path}/${top_admin}/files/Customer/${display_name}/send/"
			dropbox_path="dropbox:/Uzunov Consulting/0 Novi Dokumenti/${display_name}"

			# the rclone.conf file string muest be your cloud destination

	    dropbox_path="${external_cloud_path_base}/${display_name}"
	    if [ ! -d "${user_out_dir}" ]; then
				sudo -u www-data mkdir -p "${user_out_dir}"
	    fi
			if [ ! -d "${user_in_dir}" ]; then
				sudo -u www-data mkdir -p "${user_in_dir}"
			fi
			if [ ! -d "${admin_dir}" ]; then
				sudo -u www-data mkdir -p "${admin_in_dir}"
			fi
			if [ ! -d "${admin_dir}" ]; then
				sudo -u www-data mkdir -p "${admin_out_dir}"
			fi
	    sudo -u www-data rsync -ac "${user_out_dir}" "${admin_in_dir}"

	    # echo "${drop_path}"
			# dropbox folder creation and rsync of files to dropbox
    	rclone mkdir "${dropbox_path}"
	    rclone copy "${user_out_dir}" "${dropbox_path}"
#	    sudo -u www-data rm -f ${user_out_dir}/*
			sudo -u www-data rsync -ac 	"${admin_out_dir}" "${user_in_dir}"
	    docker exec -u 33 nextclouduzunov_app_1 ./occ files:scan -n ${user}
	done
	docker exec -u 33 nextclouduzunov_app_1 ./occ files:scan -n ${top_admin}
	#echo "Let's sleep"
sleep 42
done
