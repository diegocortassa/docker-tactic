############################################################
# Dockerfile to run Tactic Containers 
# Based on Centos 6 image
############################################################

FROM centos:centos6
MAINTAINER Diego Cortassa <diego@cortassa.net>

ENV REFRESHED_AT 2016-01-19

# Reinstall glibc-common to get deleted files (i.e. locales, encoding UTF8) from the centos docker image
#RUN yum -y reinstall glibc-common
RUN yum -y update glibc-common

# Setup a minimal env
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV HOME /root

# set a better shell prompt
RUN echo 'export PS1="[\u@docker] \W # "' >> /root/.bash_profile

# Install dependecies
RUN yum -y install httpd postgresql postgresql-server postgresql-contrib python-lxml python-imaging python-crypto python-psycopg2 unzip ImageMagick
# TODO add ffmpeg

# install supervisord
RUN /bin/rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm && \
    yum -y install python-setuptools && \
    easy_install supervisor && \
    mkdir -p /var/log/supervisor && \ 
    mkdir -p /etc/supervisor/conf.d/
ADD supervisord.conf /etc/supervisor/supervisord.conf

# Ssh server
# install ssh
# start and stop the server to make it generate host keys
RUN yum -y install openssh-server && \
    service sshd start && \
    service sshd stop
# set root passord at image launch with -e ROOT_PASSWORD=my_secure_password
ADD setup.sh /usr/local/bin/setup.sh

# Clean up
RUN yum clean all

# initialize postgresql data files
RUN service postgresql initdb

# get and install Tactic
RUN curl -O http://community.southpawtech.com/sites/default/files/download/TACTIC%20-%20Enterprise/TACTIC-4.3.0.v02.zip && \
    unzip TACTIC-4.3.0.v02.zip >/dev/null ; rm TACTIC-4.3.0.v02.zip && \
    cp TACTIC-4.3.0.v02/src/install/postgresql/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf && \
    chown postgres:postgres /var/lib/pgsql/data/pg_hba.conf && \
    service postgresql start && \
    yes | python TACTIC-4.3.0.v02/src/install/install.py -d && \
    service postgresql stop && \
    cp /home/apache/tactic_data/config/tactic.conf /etc/httpd/conf.d/ && \
    rm -r TACTIC-4.3.0.v02

EXPOSE 80 22

# Start Tactic stack
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
