#!/bin/bash
set -e

# Set root password
if [[ -n "$ROOT_PASSWORD" ]]; then 
    echo "root:${ROOT_PASSWORD}" | chpasswd
fi

/usr/bin/supervisord -c /etc/supervisor/supervisord.conf

