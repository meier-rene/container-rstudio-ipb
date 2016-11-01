#!/bin/bash

# Name
NAME="korseby/rstudio-ipb"

# CPU options
CPUS="8"
CPU_SHARES="--cpu-shares=${CPUS}"
CPU_SETS="--cpuset-cpus=0-$[${CPUS}-1]"
CPU_MEMS="--cpuset-mems=0"
MEM="--memory=24g"



# Prepare docker
#docker info
#docker pull ubuntu

# Adding infrastructure outside of docker context to work
PWD="$(pwd)"
mkdir -p etc
alias cp='cp'
cp -r -f /etc/ldap.conf etc/ldap.conf
cp -r -f /etc/ldap etc/ldap
cp -r -f /etc/pam.d etc/pam.d
cp -r -f /etc/nsswitch.conf etc/nsswitch.conf
su -c "cp -r -f /etc/nslcd.conf etc/nslcd.conf"
su -c "chmod 666 etc/nslcd.conf"
mkdir -p etc/ssl/certs
cp -r -f /etc/ssl/certs/I* etc/ssl/certs/

# Build docker
docker build --no-cache --rm=true $CPU_SHARES $CPU_SETS $CPU_MEMS $MEM --tag=$NAME .
