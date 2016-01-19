#! /bin/bash
TIMESTAMP=`date +%Y-%m-%d`
alias docker='sudo docker.io'
sed -i "s/ENV REFRESHED_AT .*$/ENV REFRESHED_AT $TIMESTAMP/" Dockerfile
docker build -t diegocortassa/tactic .
docker build -t diegocortassa/tactic:4.3.0.v02 .
