#! /bin/bash
TIMESTAMP=`date +%Y-%m-%d`
sed -i "s/ENV REFRESHED_AT .*$/ENV REFRESHED_AT $TIMESTAMP/" Dockerfile
sudo docker build -t diegocortassa/tactic .
sudo docker build -t diegocortassa/tactic:4.8 .
sudo docker build -t diegocortassa/tactic:4.8.0 .
sudo docker push diegocortassa/tactic
sudo docker push diegocortassa/tactic:4.8
sudo docker push diegocortassa/tactic:4.8.0
