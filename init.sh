#!/bin/bash
readonly MONGODB_PORTS=(27017 27018 27019)

# Clear all ports to ensure no application is running
for i in "${MONGODB_PORTS[@]}"
do
mongo --port $i admin --eval 'db.shutdownServer()'
done

# Run all nodes in mongodb replica set while starting the machine
mongod --config "~/MongoDB/mongodbPrimary.conf" --fork
mongod --config "~/MongoDB/mongodSecondary1.conf" --fork
mongod --config "~/MongoDB/mongodSecondary2.conf" --fork