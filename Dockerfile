# Use an official Python runtime as a parent image
FROM ubuntu:16.04

# Set the working directory
WORKDIR /home/vagrant

# Copy the current directory contents into the container at /home/vagrant
COPY ./setup.sh /home/vagrant
COPY ./init.sh /home/vagrant

# Setup mongodb replica set
RUN apt-get update
RUN yes | apt-get install openssl libssl-dev
RUN ./setup.sh

# Make replica set ports available to the world outside this container
EXPOSE 27017
EXPOSE 27018
EXPOSE 27019

# Run "init.sh" when the container launches
CMD ["./init.sh"]