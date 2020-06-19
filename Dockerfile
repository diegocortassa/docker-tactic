############################################################
# Dockerfile to run Tactic Containers 
# Based on Centos 6 image
############################################################

FROM centos:centos8
MAINTAINER Diego Cortassa <diego@cortassa.net>

ENV REFRESHED_AT 2020-06-20

# Install locale not included in centos docker image
RUN dnf -y install glibc-langpack-en
RUN dnf -y update && dnf clean all

# Setup a minimal env
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
# ENV LC_ALL en_US.UTF-8
ENV HOME /root

# set a better shell prompt
RUN echo 'export PS1="[\u@docker] \W # "' >> /root/.bash_profile

# Install dependecies
RUN dnf -y install epel-release
RUN dnf -y install httpd postgresql postgresql-server openssh-server python38 unzip git ImageMagick
run pip3 install psycopg2-binary pillow lxml pycryptodomex six pytz jaraco.functools requests supervisor

# add ffmpeg
RUN curl -L -O https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz && \
    tar xf ffmpeg-release-amd64-static.tar.xz && \
    cp ffmpeg-*-static/ffmpeg ffmpeg-*-static/ffprobe ffmpeg-*-static/qt-faststart /usr/local/bin/ && \
    rm -rf ffmpeg-*-static*

# generate host keys for sshd server
RUN /usr/bin/ssh-keygen -A

# set root passord at image launch with -e ROOT_PASSWORD=my_secure_password
ADD bootstrap.sh /usr/local/bin/bootstrap.sh

# Clean up
RUN dnf clean all

# initialize postgresql data files
#RUN postgresql-setup initdb
RUN su - postgres -c "/usr/bin/initdb -D /var/lib/pgsql/data"

# get and install Tactic
RUN git clone -b 4.7 --depth 1 https://github.com/Southpaw-TACTIC/TACTIC.git && \
    cp TACTIC/src/install/postgresql/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf && \
    chown postgres:postgres /var/lib/pgsql/data/pg_hba.conf && \
    su postgres -c "postgres -p 5432 -D /var/lib/pgsql/data &" && \
    sleep 5 && \
    sed -i -e 's|/home/apache|/opt/tactic|g' TACTIC/src/install/install.py && \
    yes | python3 TACTIC/src/install/install.py -d && \
    chown -R apache:apache /opt/tactic && \
    sed -i -e 's|<python>python</python>|<python>python3</python>|' /opt/tactic/tactic_data/config/tactic-conf.xml && \
    cp /opt/tactic/tactic_data/config/tactic.conf /etc/httpd/conf.d/ && \
    pkill postgres && \
    rm -rf TACTIC

EXPOSE 80 22

# configure supervisord
RUN mkdir -p /var/log/supervisor && \
    mkdir -p /etc/supervisor/conf.d/
ADD supervisord.conf /etc/supervisor/supervisord.conf

# Start Tactic stack
CMD ["/usr/local/bin/bootstrap.sh"]

