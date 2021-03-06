#!/usr/bin/env bash
#
#   Builds and runs a docker container, within which it starts an nginx
#   reverse-proxy
#
#   Use Ctrl-C to stop the containers.
#
#   After the first build, the docker image is retained, so subsequent runs
#   will not rebuild the docker, but just start a new container from the image.
#	If you need to rebuild the docker use the `--force-recreate`. 
#	
#	To remove all containers, images, volumes without rebuilding do
#	`bin/docker-rm`
#

# Get the path to this script (regardless of current working dir).
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

# Was the --prod flag set? (remove it from the args if so.)
ARGS=""; ENV_MODE=dev
for var in "$@"; do test "$var" != '--prod' && ARGS="$ARGS $var" || ENV_MODE=prod; done
ARGS=$(echo "$ARGS" | xargs)    # Trim whatespace around variables

# Was the --stage flag set? (remove it from the args if so.)
OLD_ARGS=$ARGS; ARGS=""
for var in $OLD_ARGS; do test "$var" != '--stage' && ARGS="$ARGS $var" || ENV_MODE=stage; done
ARGS=$(echo "$ARGS" | xargs)    # Trim whatespace around variables

# Was the --dev flag set? (remove it from the args if so.)
OLD_ARGS=$ARGS; ARGS=""
for var in $OLD_ARGS; do test "$var" != '--dev' && ARGS="$ARGS $var" || ENV_MODE=dev; done
ARGS=$(echo "$ARGS" | xargs)    # Trim whatespace around variables

# Was the --no-ssl flag set? (remove it from the args if so.)
OLD_ARGS=$ARGS; ARGS=""; export USE_SSL=1
for var in $OLD_ARGS; do test "$var" != '--no-ssl' && ARGS="$ARGS $var" || export USE_SSL=0; done
ARGS=$(echo "$ARGS" | xargs)    # Trim whatespace around variables

# Based on what environment we're in (production, staging, development), we
# need to set some environment variables, including secrets.
case "$ENV_MODE" in
	dev)
		source .env
		;;
	stage)
		source <(gpg -d .env.gpg)
		export HOST=$STAGE_HOST
		;;
	prod)
		source <(gpg -d .env.gpg)
		export HOST=$PROD_HOST
		;;
esac

# Fill in variables in the nginx config so internal redirects work and
# certificates can be found.
$SCRIPTPATH/bin/fill_template.py\
	$SCRIPTPATH/config/nginx-config-template\
	cert_path=/app/cert/ server_name=$HOST\
	node_host=$NODE_HOST node_port=$NODE_PORT\
   	> $SCRIPTPATH/config/nginx-config 
$SCRIPTPATH/bin/fill_template.py\
	$SCRIPTPATH/config/nginx-config-nossl-template\
	cert_path=/app/cert/ server_name=$HOST\
	node_host=$NODE_HOST node_port=$NODE_PORT\
	> $SCRIPTPATH/config/nginx-config-nossl

# Verify that environment varibles, needed by app services, are set.
MISSED=0
if [ -z "$PROJ_NAME" ]; then echo "Need to set PROJ_NAME." && MISSED=1; fi
if [ -z "$USE_SSL" ]; then echo "Need to set USE_SSL." && MISSED=1; fi
if [ -z "$HOST" ]; then echo "Need to set HOST." && MISSED=1; fi
if [ $MISSED -eq 1 ]; then exit 1; fi

# Notify whether SSL being used; if yes, ensure certificate-related files exist.
if [ -z $USE_SSL ] || [ $USE_SSL -eq 0 ]; then
    echo "NO SSL"
else
    echo "Using SSL"
    CERT_PATH=$SCRIPTPATH/cert
	MESSAGE="\nDo you need to get a SSL certificate?  See README."
    if [ ! -f $CERT_PATH/dhparam.pem ]; then
         echo -e "SSL: expected $CERT_PATH/dhparam.pem$MESSAGE"; exit 1; fi
    if [ ! -f $CERT_PATH/fullchain.pem ]; then
        echo "SSL: expected $CERT_PATH/fullchain.pem$MESSAGE"; exit 1; fi
    if [ ! -f $CERT_PATH/privkey.pem ]; then
        echo "SSL: expected $CERT_PATH/privkey.pem$MESSAGE"; exit 1; fi
fi

# Figure out if --force-recreate was included as an arg.  If so, remove all
# images, volumes, and containers
for var in "$ARGS"; do 
    if [ "$var" = "--force-recreate" ]; then
        echo "removing images, volumes, and containers"
        bin/docker-rm &> /dev/null
    fi
done

# Now call docker-compose, and pass through all the arguments
echo 'starting dockers...'
docker-compose -p mern -f docker/docker-compose.yml up $ARGS 2> .build-err
