############################################################
# Dockerfile to run a Tactic Container
# Based on Centos 8 image
############################################################

FROM centos:centos8
MAINTAINER Diego Cortassa <diego@cortassa.net>

ENV REFRESHED_AT 2021-03-29

# Install locale (not included in centos docker image)
RUN dnf -y install glibc-langpack-*
RUN dnf -y update

#RUN apt-get install -y locales && \
#    locale-gen C.UTF-8 && \
#    /usr/sbin/update-locale LANG=C.UTF-8

# Setup a minimal env
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV HOME /root

# set a better shell prompt
RUN echo 'export PS1="[\u@tactic-docker] \W # "' >> /root/.bash_profile

# Install dependecies
RUN dnf -y install epel-release
RUN dnf -y install \
    httpd \
    postgresql \
    postgresql-server \
    python38 \
    unzip \
    git-core \
    ImageMagick && \
    dnf clean all

RUN pip3 install \
    psycopg2-binary \
    pillow \
    lxml \
    pycryptodomex \
    six \
    pytz \
    jaraco.functools \
    requests \
    supervisor

# add ffmpeg
RUN curl -L -O https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz && \
    tar xf ffmpeg-release-amd64-static.tar.xz && \
    cp ffmpeg-*-static/ffmpeg ffmpeg-*-static/ffprobe ffmpeg-*-static/qt-faststart /usr/local/bin/ && \
    rm -rf ffmpeg-*-static*

# get Tactic source
RUN git clone -b 4.8 --depth 1 https://github.com/Southpaw-TACTIC/TACTIC.git
RUN cp TACTIC/src/install/apache/tactic.conf /etc/httpd/conf.d/

EXPOSE 80 22

# configure supervisord
RUN mkdir -p /var/log/supervisor && \
    mkdir -p /etc/supervisor/conf.d/
ADD supervisord.conf /etc/supervisor/supervisord.conf

# copy start script
ADD bootstrap.sh /usr/local/bin/bootstrap.sh

# Start Tactic stack
CMD ["/usr/local/bin/bootstrap.sh"]

