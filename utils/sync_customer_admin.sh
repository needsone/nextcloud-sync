#!/bin/bash

top_admin="admin"

while [ 1 ]
do
	for user in `docker exec -u 33 nextclouduzunov_app_1 ./occ  group:list --output=json | jq -r .customer[] -c` ; do
	    display_name=`docker exec -u 33 nextclouduzunov_app_1 ./occ user:info ${user} --output=json | jq -r .display_name`

	    user_out_dir="/data/nextclouduzunov/app/data/${user}/files/Documents for your Fiduciary/"
			user_in_dir="/data/nextclouduzunov/app/data/${user}/files/Documents from your Fiduciary/"
	    admin_in_dir="/data/nextclouduzunov/app/data/${top_admin}/files/Customer/${display_name}/in"
			admin_out_dir="/data/nextclouduzunov/app/data/${top_admin}/files/Customer/${display_name}/in"
	    dropbox_path="dropbox:/Uzunov Consulting/0 Novi Dokumenti/${display_name}"

			if [ ! -d "${user_dir}" ]; then
				sudo -u www-data mkdir -p "${user_dir}"
	    fi
	    if [ ! -d "${user_out_dir}" ]; then
				sudo -u www-data mkdir -p "${user_out_dir}"
	    fi
			if [ ! -d "${user_in_dir}" ]; then
				sudo -u www-data mkdir -p "${user_in_dir}"
			fi
	    if [ ! -d "${admin_dir}" ]; then
        sudo -u www-data mkdir -p "${admin_out_dir}"
      fi
			if [ ! -d "${admin_dir}" ]; then
								sudo -u www-data mkdir -p "${admin_in_dir}"
			fi
	    sudo -u www-data rsync -acv "${user_out_dir}" "${admin_in_dir}"
	    # echo "${drop_path}"
    	rclone mkdir "${dropbox_path}"
	    rclone copy "${user_out_dir}" "${dropbox_path}"
	    sudo -u www-data rm -f ${user_out_dir}/*
	    docker exec -u 33 nextclouduzunov_app_1 ./occ files:scan -n ${user}
	done
	docker exec -u 33 nextclouduzunov_app_1 ./occ files:scan -n ${top_admin}
	#echo "Let's sleep"
sleep 42
done
