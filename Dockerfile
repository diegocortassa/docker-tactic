############################################################
# Dockerfile to run a Tactic Container
# Based on Rocky Linux 8 image
############################################################

FROM rockylinux:8
MAINTAINER Diego Cortassa <diego@cortassa.net>

ENV REFRESHED_AT 2022-02-07

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
    python39 \
    unzip \
    xz \
    git-core \
    ImageMagick

# Needed to build python-ldap
RUN dnf -y install gcc python39-devel openldap-devel

RUN pip3 install \
    psycopg2-binary \
    pillow \
    lxml \
    pycryptodomex \
    six \
    pytz \
    jaraco.functools \
    requests \
    python-ldap \
    supervisor

# remove unneeded packages
RUN dnf -y remove \
    cpp \
    cyrus-sasl \
    cyrus-sasl-devel \
    glibc-devel \
    glibc-headers \
    isl \
    kernel-headers \
    libmpc \
    libxcrypt-devel && \
    dnf clean all

# add ffmpeg
RUN curl -L -O https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz && \
    tar xf ffmpeg-release-amd64-static.tar.xz && \
    cp ffmpeg-*-static/ffmpeg ffmpeg-*-static/ffprobe ffmpeg-*-static/qt-faststart /usr/local/bin/ && \
    rm -rf ffmpeg-*-static*

# get Tactic source
RUN git clone -b 4.8 --depth 1 https://github.com/Southpaw-TACTIC/TACTIC.git
RUN cp TACTIC/src/install/apache/tactic.conf /etc/httpd/conf.d/

EXPOSE 80

# configure supervisord
RUN mkdir -p /var/log/supervisor && \
    mkdir -p /etc/supervisor/conf.d/
ADD supervisord.conf /etc/supervisor/supervisord.conf

# copy start script
ADD bootstrap.sh /usr/local/bin/bootstrap.sh

# Start Tactic stack
CMD ["/usr/local/bin/bootstrap.sh"]

