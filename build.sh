#! /bin/bash
docker pull centos
docker build -t diegocortassa/tactic .
docker build -t diegocortassa/tactic:4.3.0.v01 .
