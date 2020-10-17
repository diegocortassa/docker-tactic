docker-tactic
=================

Tactic docker image.

TACTIC
------
TACTIC is a dynamic, open-source, web-based platform used for building enterprise solutions. It combines elements of traditional DAM, PAM, CMS and workflow management systems to optimize busy work environments. Read more at [Southpaw Technology web site](http://www.southpawtech.com/tactic/)

Docker Image
------------
This docker image is intended as an easy all in one installation to start experimenting with tactic including a postgresql server and an apache server. For a production server it is better to run tactic, postgresql and apache into different containers
The built image is available on the [Docker index](https://index.docker.io/) as **diegocortassa/tactic**
Dockerfile and source files can be found on [github](https://github.com/diegocortassa/docker-tactic)

Install docker on your host
On a recent ubuntu just use "sudo apt-get update; sudo apt-get install docker.io", (I usually add an alias "alias docker='sudo docker.io'" to my .bashrc)

Download image with:

    $ docker docker pull diegocortassa/tactic

Run the container with:

    $ docker run -d --name tactic --volume=/tactic-docker/tactic:/opt/tactic --volume=/tactic-docker/postgres-data:/var/lib/pgsql/data -p 80:80 diegocortassa/tactic

/opt/tactic contains tactic config and data
/var/lib/pgsql/data contains the postgres database

- connect with your browser to http://localhost to use tactic.

