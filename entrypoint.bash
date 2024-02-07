#! /bin/bash
set -euxE

LETCD="/usr/local/etc/php81"
CONFD="${LETCD}/conf.d"
DATAD="/srv/data/php81"

if ! [[ -n $(ls -1A ${CONFD}) ]]; then
    echo "ERROR: there are no configuration files to be included in directory: '${CONFD}' " >&2
    exit 100
fi

if ! [[ -d ${DATAD} ]]; then mkdir -p "${DATAD}"; fi
chmod ug=rwX,o-rX -R "${DATAD}"

if ! [[ -d "${DATAD}/log" ]]; then mkdir -p "${DATAD}/log"; fi
chmod ug=rwX,o-rX -R "${DATAD}/log"

exec /usr/sbin/php-fpm81 -F -c "${CONFD}/php.fpm.ini" -y "${LETCD}/php-fpm.conf"
