#! /bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "This script needs to be run as root."
    exit 1
fi

showhelp () {
    echo "Usage: ./install.sh -f /path/to/file [options]
    -h, --help, -?
                Display usage information
    -f, --file
                The file to upload. Mandatory!
    -t, --target
                Override the target file. Can be filename or relative path (/assets/css/foo.css). Default is oauth.approval.page.template.html"
    exit 0
}

PF_USER="ping8cii"
SERVERS="172.18.188.11 172.18.188.12 172.18.181.36 172.18.181.37"
TARGET_DIR="/apps/infra/pingfederate-8.3.1-runtime-cii/pingfederate/server/default/conf/template"
TARGET="oauth.approval.page.template.html"

TEMPLATE_FILE=""


while :; do
    case "$1" in
        --help)
            showhelp
            ;;
        --admin)
            IS_ADMIN='t'
            ;;
        --file)
            if [ "$2" ]; then
                TEMPLATE_FILE=$2
                if [ -f "${TEMPLATE_FILE}" ]; then
                    shift 2
                    continue
                else
                    echo "ERROR: No file found at ${TEMPLATE_FILE}" >&2
                    exit 1
                fi
            else
                echo 'ERROR: Must specify a non-empty "--file FILE" argument.' >&2
                exit 1
            fi
            ;;
        --file=?*)
            PF_ARCHIVE=${1#*=} # Delete everything up to "=" and assign the remainder.
            if [ ! -f "${PF_ARCHIVE}" ]; then
                echo "ERROR: No file found at ${PF_ARCHIVE}" >&2
                exit 1
            fi
            ;;
        --file=)
            echo 'ERROR: Must specify a non-empty "--file FILE" argument.' >&2
            exit 1
            ;;
        --target)
            if [ "$2" ]; then
                TARGET=$2
                shift 2
                continue
            else
                echo 'ERROR: Must specify a non-empty "--target TARGET" argument.' >&2
                exit 1
            fi
            ;;
        --target=?*)
            TARGET=${1#*=} # Delete everything up to "=" and assign the remainder.
            ;;
        --target=)
            echo 'ERROR: Must specify a non-empty "--target=TARGET" argument.' >&2
            exit 1
            ;;
        --)
            shift
            break
            ;;
        -h|\?)
            showhelp
            ;;
        -f)
            if [ "$2" ]; then
                TEMPLATE_FILE=$2
                if [ -f "${TEMPLATE_FILE}" ]; then
                    shift 2
                    continue
                else
                    echo "ERROR: No file found at ${TEMPLATE_FILE}" >&2
                    exit 1
                fi
            else
                echo 'ERROR: Must specify a non-empty "--file FILE" argument.' >&2
                exit 1
            fi
            ;;
         -t)
            if [ "$2" ]; then
                TARGET=$2
                shift 2
                continue
            else
                echo 'ERROR: Must specify a non-empty "--target TARGET" argument.' >&2
                exit 1
            fi
            ;;
         -*)
            echo "$0: error - unrecognized option '${1:$i:1}'" >&2;
            echo "Try 'install --help' for more information."
            exit 1
            ;;
         *)
            break
            ;;
    esac
    shift
done

for SERVER in $SERVERS; do
    MACHINE=$(uname -s)
    if [ "${MACHINE}" = "Darwin" ]; then
        brew install -y expect
    fi

    expect -c "spawn scp -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${TEMPLATE_FILE} ${PF_USER}@${SERVER}:${TARGET_DIR}/${TARGET}
expect \"assword:\"
send \"${PF_USER}\r\"
interact"
done
