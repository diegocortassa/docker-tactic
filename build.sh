#! /bin/bash
TIMESTAMP=`date +%Y-%m-%d`
alias docker='sudo docker'
sed -i "s/ENV REFRESHED_AT .*$/ENV REFRESHED_AT $TIMESTAMP/" Dockerfile
docker build -t diegocortassa/tactic .
docker build -t diegocortassa/tactic:4.8 .
docker build -t diegocortassa/tactic:4.8.0.b05 .
docker push diegocortassa/tactic
