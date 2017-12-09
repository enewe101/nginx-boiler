#!/bin/sh
passgen () {
	date +%s | sha256sum | base64 | head -c 32 ; echo
}

# Get the path to this script (regardless of current working dir).
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

# Source .env in the root of the app, based on relative location to this script
$SCRIPTPATH/passgen.py $SCRIPTPATH/../.env.dev | gpg -co $SCRIPTPATH/../.env.prod.gpg
