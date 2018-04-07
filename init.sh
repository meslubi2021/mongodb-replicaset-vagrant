#!/bin/bash
# Inititalizing variables
readonly INSTALL_DIR="/home/vagrant"
readonly MONGODB_CONF_FILES=("mongodbPrimary.conf" "mongodbSecondary1.conf" "mongodbSecondary2.conf")
readonly MONGODB_NODES=("mongodbPrimary" "mongodbSecondary1" "mongodbSecondary2")
readonly MONGODB_PORTS=(27017 27018 27019)
readonly MONGODB_ROOT_USER="db_root"
readonly MONGODB_ROOT_PASSWORD="db@p@ss@root"

# Clear all ports to ensure no application is running
for i in "${MONGODB_PORTS[@]}"
do
mongo --port $i admin --eval 'db.auth("'"$MONGODB_ROOT_USER"'", "'"$MONGODB_ROOT_PASSWORD"'"); db.shutdownServer()'
done

# Run all nodes in mongodb replica set while starting the machine
for i in "${MONGODB_CONF_FILES[@]}"
do
  mongod --config "$INSTALL_DIR/MongoDB/$i" --fork
done