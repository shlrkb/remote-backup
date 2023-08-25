#!/bin/bash

export PATHS=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin

ENV=$HOME/remote-backup/.env
if [ -f "$ENV" ]; then
    source $HOME/remote-backup/.env
else
    echo "$ENV does not exist."
    echo "Exiting...";
exit;
fi

BACKUP_DIR=$HOME/public_html/
MYSQLDIR=$HOME/backups/

RSYNC_BIN=/usr/bin/rsync
RSYNC_OPTS="--progress -azh  --delete --ignore-errors --inplace --delete-excluded --force -4"
SSH_OPTS="-o ConnectTimeout=5"

#checking if DB directory exists. else create
if [ ! -d "$MYSQLDIR" ]; then
  mkdir $MYSQLDIR
fi

ssh -p23 $ENDPOINT mkdir /home/$DIRNAME

# rsync FILEDIR to Hetzner
echo "rsyncing files to destination..."
$RSYNC_BIN ${RSYNC_OPTS} --rsh="ssh $SSH_OPTS -c aes128-ctr" -e 'ssh -p 23' \
  --exclude "var/" \
  --exclude "logs/*" \
  --exclude "pub/media/mf_webp/" \
  --exclude "media/catalog/product/cache/" \
  --exclude "pub/media/catalog/product/cache/" \
  --exclude "app/etc/env.php" \
  $BACKUP_DIR $ENDPOINT:/home/$DIRNAME/www
echo "rsync complete"

# dump databases
echo "dumping databases..."
mysql -h 127.0.0.1 -u $MYSQLUSER -p$MYSQLPW -N -e 'show databases' | grep -Ev "^(Database|mysql|performance_schema|information_schema)$" | while read dbname; do mysqldump -h 127.0.0.1 -u $MYSQLUSER -p$MYSQLPW --complete-insert --routines --triggers --single-transaction "$dbname" | gzip -c > $MYSQLDIR/"$dbname".sql.gz; done
echo "mysqldump complete"

# rsync DBs to Hetzner
echo "rsyncing dbs to destination..."
$RSYNC_BIN ${RSYNC_OPTS} --rsh="ssh $SSH_OPTS -c aes128-ctr" -e 'ssh -p 23' $MYSQLDIR $ENDPOINT:/home/$DIRNAME/db
echo "rsync complete"

# cleanup local dbs
echo "cleaning up local dbs"
rm -rf $MYSQLDIR/$MYSQLUSER*
echo "cleanup complete"


echo "BACKUP COMPLETE"
