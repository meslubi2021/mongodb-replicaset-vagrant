#!/bin/bash
# This script setups a replica set of mongodb 3.4 version running in PSS mode (Primary, Secondary, Secondary) on a local machine.
# It assumes that the installation directory with variable INSTALL_DIR exists
# Inititalizing variables
readonly INSTALL_DIR="/home/vagrant"
readonly MONGODB_CONF_FILES=("mongodbPrimary.conf" "mongodbSecondary1.conf" "mongodbSecondary2.conf")
readonly MONGODB_NODES=("mongodbPrimary" "mongodbSecondary1" "mongodbSecondary2")
readonly MONGODB_PORTS=(27017 27018 27019)
readonly MONGODB_ROOT_USER="db_root"
readonly MONGODB_ROOT_PASSWORD="db@p@ss@root"

# Install mongodb 3.4
# Do not start mongod process with the default configuration
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6
echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.4.list
apt-get update
apt-get install -y mongodb-org


# Directory containing all the configuration/data files of mongodb nodes
mkdir "$INSTALL_DIR/MongoDB"

# Creating configuration files of all mongodb nodes
for i in "${MONGODB_CONF_FILES[@]}"
do	
	touch "$INSTALL_DIR/MongoDB/$i"	
done

# Populating Configuration Files for mongodb nodes
# TODO: bindIp should be open only to the servers which needs access to it.
# A comma seperated list of ip's should be mentioned like 172.31.31.12, 172.31.31.13 etc.
ITER=0
for i in "${MONGODB_NODES[@]}"
do
echo "$INSTALL_DIR/MongoDB/$i.conf"
echo "
systemLog:
  destination: file
  path: $INSTALL_DIR/MongoDB/$i/mongo.log
  logAppend: true

storage:
  dbPath: $INSTALL_DIR/MongoDB/$i
  journal:
    enabled: true

net:
  port: ${MONGODB_PORTS[$ITER]}
  bindIp: 0.0.0.0
" > "$INSTALL_DIR/MongoDB/$i.conf"
ITER=$(expr $ITER + 1)
done

# Creating Data/Logs directory for mongodb nodes
for i in "${MONGODB_NODES[@]}"
do
mkdir "$INSTALL_DIR/MongoDB/$i"
done


# Start the servers
for i in "${MONGODB_CONF_FILES[@]}"
do
	mongod --config "$INSTALL_DIR/MongoDB/$i" --fork
done


# Create default users on all the nodes
for i in "${MONGODB_PORTS[@]}"
do
mongo --port $i admin --eval 'db.createUser({user: "'"$MONGODB_ROOT_USER"'", pwd: "'"$MONGODB_ROOT_PASSWORD"'", roles: [ { role: "root", db: "admin" } ]})'
done


# Enforce Keyfile Access Control in a Replica Set
openssl rand -base64 756 > "$INSTALL_DIR/MongoDB/.mdbia"
chmod 400 "$INSTALL_DIR/MongoDB/.mdbia"


# Enable authorization and enter replica set name in the conf files
cd "$INSTALL_DIR/MongoDB"
for i in *.conf
do 
echo "
security:
  authorization: enabled
  keyFile: $INSTALL_DIR/MongoDB/.mdbia

replication:
  replSetName: rs1
" >> $i
done


# Reboot servers to run with new config file
for i in "${MONGODB_PORTS[@]}"
do
mongo --port $i admin --eval 'db.auth("'"$MONGODB_ROOT_USER"'", "'"$MONGODB_ROOT_PASSWORD"'"); db.shutdownServer()'
done

for i in "${MONGODB_CONF_FILES[@]}"
do
  mongod --config "$INSTALL_DIR/MongoDB/$i" --fork
done


# Initiate the replica set and add secondaries
# TODO: Find a way to use ipaddress while adding secondary node and not use not embedd client hostname
mongo --port 27017 admin --eval 'db.auth("'"$MONGODB_ROOT_USER"'", "'"$MONGODB_ROOT_PASSWORD"'"); rs.initiate({"_id":"rs1","members":[{"_id":1,"host":"127.0.0.1:27017"}]})'
mongo --port 27017 admin --eval 'db.auth("'"$MONGODB_ROOT_USER"'", "'"$MONGODB_ROOT_PASSWORD"'"); rs.add("127.0.0.1:27018")'
mongo --port 27017 admin --eval 'db.auth("'"$MONGODB_ROOT_USER"'", "'"$MONGODB_ROOT_PASSWORD"'"); rs.add("127.0.0.1:27019")'
mongo --port 27017 admin --eval 'db.auth("'"$MONGODB_ROOT_USER"'", "'"$MONGODB_ROOT_PASSWORD"'"); cfg = rs.conf(); cfg.members[0].priority = 10; cfg.members[1].priority = 1; cfg.members[2].priority = 1; rs.reconfig(cfg)'

