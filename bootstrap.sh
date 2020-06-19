#!/bin/bash
set -e

# Set root password
if [[ -n "$ROOT_PASSWORD" ]]; then 
    echo "root:${ROOT_PASSWORD}" | chpasswd
fi

/usr/local/bin/supervisord -c /etc/supervisor/supervisord.conf

