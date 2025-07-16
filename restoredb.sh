DB_BACKUP_FILENAME="/home/robert/aquinasbackup/backup-2025-07-15.dump"
PROD_BACKUP_FILE="/home/robert/thomas/backup/backup.dump"  # Directory on production server for backups
PROD_SERVER="rwvagatha.duckdns.org" 
DOCKER_COMPOSE_FILE="/home/robert/thomas/docker-compose-pull.yml"
DB_USERNAME="robert"
DB_NAME="agatha_production"


# Copy the compressed SQL file (or custom dump) to your home directory on the remote host
scp $DB_BACKUP_FILENAME $PROD_SERVER:$PROD_BACKUP_FILE
ssh $PROD_SERVER docker compose -f $DOCKER_COMPOSE_FILE exec db pg_restore --verbose --clean --create --username=$DB_USERNAME --dbname=$DB_NAME $PROD_BACKUP_FILE


