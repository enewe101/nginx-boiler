#!/usr/bin/env bash
docker exec -it mern_nginx_1 bash -c 'bash --init-file <(echo "/app/bin/get-cert-in-docker.sh")'
