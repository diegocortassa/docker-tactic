#!/bin/bash
set -e

# initialize postgresql data files
if [[ ! -e "/var/lib/pgsql/data/PG_VERSION" ]]; then
    echo "*** Tactic Docker First Run: initializing postgres data"
    mkdir -p /var/lib/pgsql/data
    chown -R postgres:postgres /var/lib/pgsql/data
    su - postgres -c "/usr/bin/initdb -D /var/lib/pgsql/data"
    echo "*** Tactic Docker First Run: postgres data initialized"
fi

# Install tactic
if [[ ! -e "/opt/tactic/tactic/VERSION" ]]; then
    echo "*** Tactic Docker First Run: installing tactic"
    cp TACTIC/src/install/postgresql/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf
    chown postgres:postgres /var/lib/pgsql/data/pg_hba.conf
    su - postgres -c "pg_ctl -w -D /var/lib/pgsql/data start"
    yes | python3 TACTIC/src/install/install.py -d
    chown -R apache:apache /opt/tactic/tactic_temp
    sed -i -e 's|<python>python</python>|<python>python3</python>|' /opt/tactic/tactic_data/config/tactic-conf.xml
    su - postgres -c "pg_ctl -w -D /var/lib/pgsql/data stop"
    echo "*** Tactic Docker First Run: tactic installed"
else
   # If the docker image version was updated reinstall tactic and update db
   INTALLED_VERSION=$(cat /opt/tactic/tactic/VERSION)
   IMAGE_VERSION=$(cat TACTIC/VERSION)
   if [[ "$INTALLED_VERSION" !=  "$IMAGE_VERSION" ]] ; then
       echo "*** Tactic Docker New version: upgrading"
       # save old config file
       cp /opt/tactic/tactic_data/config/tactic-conf.xml /opt/tactic/tactic_data/config/tactic-conf.xml.$$.tmp
       su - postgres -c "pg_ctl -w -D /var/lib/pgsql/data start"
       yes | python3 TACTIC/src/install/install.py -d --install_db false
       chown -R apache:apache /opt/tactic/tactic_temp
       # restore old config file
       cp /opt/tactic/tactic_data/config/tactic-conf.xml.$$.tmp /opt/tactic/tactic_data/config/tactic-conf.xml
       su - apache -s /bin/bash -c "python3 /opt/tactic/tactic/src/bin/upgrade_db.py -y"
       su - postgres -c "pg_ctl -w -D /var/lib/pgsql/data stop"
   fi

    #
    PY3_LIB=`/usr/bin/python3 -c 'from distutils.sysconfig import get_python_lib; import sys; sys.stdout.write(get_python_lib())'`
    TACTIC_ENV_DIR="$PY3_LIB/tacticenv"
    mkdir -p "$TACTIC_ENV_DIR"
    cp /opt/tactic/tactic/src/install/data/* "$PY3_LIB/tacticenv/"
    echo "TACTIC_INSTALL_DIR='/opt/tactic/tactic'" >> "$PY3_LIB/tacticenv/tactic_paths.py"
    echo "TACTIC_SITE_DIR=''" >> "$PY3_LIB/tacticenv/tactic_paths.py"
    echo "TACTIC_DATA_DIR='/opt/tactic/tactic_data'" >> "$PY3_LIB/tacticenv/tactic_paths.py"
    echo "" >> "$PY3_LIB/tacticenv/tactic_paths.py"

fi

/usr/local/bin/supervisord -c /etc/supervisor/supervisord.conf

