# Shell script to backup remote server on demand
**Imprisoned for a specific task and weakly customized. Lies here not to get lost.**

## Prerequirements
```bash
cp .env.example .env
```

## Configuration - variables in `.env` file
**BACKUP_PROJECTS_FOLDER**=/home/user/www

Path to projects with one level structure. Used to search custom backup scripts. For example:

```
- /home/webulla/www/webulla.ru
- /home/webulla/www/landing.webulla.ru
```

**BACKUP_CLOUD_FOLDER**=/home/user/www/cloud.domain.ru/web

Path to folder which is static files storage. Will be dumped as a zip archive.

**BACKUP_TARGET_FOLDER**=/home/user/backups

Where to save backups (will be created or cleaned).

**BACKUP_CUSTOM_FILE**=backup.sh

Files to execute in each top-level folder in **BACKUP_PROJECTS_FOLDER**. For example, in this example (backup.sh) the following commands will be executed.

```bash
sh /home/user/www/webulla.ru/backup.sh $BACKUP_TARGET_FOLDER
sh /home/user/www/webulla.ru/backup.sh $BACKUP_TARGET_FOLDER
```

**BACKUP_MYSQL_USER**=root

Mysql user to dump all databases for this user.

**BACKUP_MYSQL_PASSWORD**=root

Mysql password for **BACKUP_MYSQL_USER**.

## Download remote backup folder
```bash
cd && rsync -chavzP --stats user@host.ru:/home/user/backups .
```