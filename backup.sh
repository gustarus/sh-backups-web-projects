#!/bin/bash

# function to display commands
exe() { echo "\$ $@" ; "$@"; }

# local configuration
folder=$(dirname "$0")

# load backups variables
export $(cat "${folder}"/.env | xargs) || exit 1

# creating variables
sourceProjectsFolder="${BACKUP_PROJECTS_FOLDER}"
sourceCloudFolder="${BACKUP_CLOUD_FOLDER}"
sourceCustomFile="${BACKUP_CUSTOM_FILE}"

targetFolder="${BACKUP_TARGET_FOLDER}"/"$(date +%Y-%m-%d)"
targetFolderCustom="${targetFolder}"/custom
targetFolderMysql="${targetFolder}"/mysql
targetFolderCloud="${targetFolder}"/cloud

# mysql configuration
mysqlCmd=/usr/bin/mysql
mysqlDumpCmd=/usr/bin/mysqldump
mysqlUser="${BACKUP_MYSQL_USER}"
mysqlPassword="${BACKUP_MYSQL_PASSWORD}"


# creating backup folders
echo "Creating target folders..."
exe mkdir -p "${targetFolderCustom}"
exe mkdir -p "${targetFolderMysql}"
exe mkdir -p "${targetFolderCloud}"

# clean target folder if not empty
echo "Cleaning target folder if already not empty..."
exe rm -rf ${targetFolderCustom}/*
exe rm -rf ${targetFolderMysql}/*
exe rm -rf ${targetFolderCloud}/*


# stepping into the folder
exe cd "${sourceProjectsFolder}"

# looping the subfolders for custom dumping scrips
for D in *; do
    if [ -d "${D}" ]; then
    	# running custom dump script
        if [ -f "${D}"/"${sourceCustomFile}" ]; then
        	pathToProjectSource="${sourceProjectsFolder}"/"${D}"
        	pathToProjectTarget="${targetFolderCustom}"/"${D}"

        	exe mkdir -p "${pathToProjectTarget}"
        	exe cd "${pathToProjectSource}"
        	exe sh "${sourceCustomFile}" "${pathToProjectTarget}"
		fi
    fi
done


# select databases list
echo "Select allowed databases for user ${mysqlUser}..."
databases=`$mysqlCmd -u$mysqlUser -p$mysqlPassword -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema)"`

# dump selected databases 
echo "Dump all selected databases..."
for db in $databases; do
  echo "Dump database ${db}..."
  $mysqlDumpCmd --force --opt --user=$mysqlUser -p$mysqlPassword --databases $db | gzip > "${targetFolderMysql}/$db.gz"
done


# backuping cloud (static files from one folder)
echo "Backuping cloud from ${sourceCloudFolder}..."
exe zip -r "${targetFolderCloud}"/cloud.zip "${sourceCloudFolder}"


echo "Complete!"