# mongodb-replicaset-vagrant
[Vagrant](https://www.vagrantup.com/) configuration to run a mongodb replica set on any OS.

This setup boots up a 4 gig ubuntu xenial (16.04) machine running with mongodb (3.4) in a PSS (Primary, Secondary, Secondary) [replica set](https://docs.mongodb.com/v3.4/replication/) configuration. 

A user with [root role](https://docs.mongodb.com/v3.4/tutorial/manage-users-and-roles/) is created by default. Username and Password are available in setup.sh. Please change the username and password as per your needs. 

All nodes of the replica set run on ports as mentioned below. All ports are forwarded to the local machine. You should be able to connect to the replica set with any mongodb management tool like [Robo3T](https://robomongo.org/).

Primary Node - 27017

Secondary Node 1 - 27018

Secondary Node 2- 27019

Know More About [Configuring mongodb-replicaset](https://medium.com/docon/configuring-mongodb-3-4-replica-set-on-ubuntu-16-04-d4c91f9e9f8).

## Prerequisite
1. Vagrant setup needs to be configured on the local machine. Know more about how to setup [vagrant](https://www.vagrantup.com/intro/getting-started/install.html).

## Usage
1. Clone the repository on your local machine
2. Run `vagrant up` to start the vagrant machine.

## SSH

```
# Get key file
vagrant ssh-config | grep IdentityFile
ssh vagrant@localhost -p 2222 -i <identityfile-localtion>
```
