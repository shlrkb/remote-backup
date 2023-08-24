#!/bin/bash

export PATHS=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin

### EDIT THIS BRACKET TO YOUR NEEDS ###

export DIRNAME=fx_mage2.dk
export ENDPOINT=user@servername

export MYSQLUSER=fx_mage2_dk
export MYSQLPW=dit_mysql_password

### END EDIT ###

BACKUP_DIR=$(pwd)/public_html/
MYSQLDIR=$(pwd)/backups/

RSYNC_BIN=/usr/bin/rsync
RSYNC_OPTS="--progress -azh  --delete --ignore-errors --inplace --delete-excluded --force -4"
SSH_OPTS="-o ConnectTimeout=5"

ROPTS="--exclude public_html/var --exclude public_html/media/catalog/product/cache --exclude public_html/pub/media/catalog/product/cache"

#checking if DB directory exists. else create
if [ ! -d "$MYSQLDIR" ]; then
  mkdir $MYSQLDIR
fi

ssh -p23 $ENDPOINT mkdir /home/$DIRNAME

# rsync FILEDIR to Hetzner
echo "rsyncing files to destination..."
$RSYNC_BIN ${RSYNC_OPTS} --rsh="ssh $SSH_OPTS -c aes128-ctr" -e 'ssh -p 23' $ROPTS $BACKUP_DIR $ENDPOINT:/home/$DIRNAME/www
echo "rsync complete"

# dump databases
echo "dumping databases..."
mysql -h 127.0.0.1 -u $MYSQLUSER -p$MYSQLPW -N -e 'show databases' | grep -Ev "^(Database|mysql|performance_schema|information_schema)$" | while read dbname; do mysqldump -h 127.0.0.1 -u $MYSQLUSER -p$MYSQLPW --complete-insert --routines --triggers --single-transaction "$dbname" | gzip -c > $MYSQLDIR/"$dbname".sql.gz; done
echo "mysqldump complete"

$RSYNC_BIN ${RSYNC_OPTS} --rsh="ssh $SSH_OPTS -c aes128-ctr" -e 'ssh -p 23' $MYSQLDIR $ENDPOINT:/home/$DIRNAME/db
