#!/usr/bin/env bash
docker kill dev-mongo-container &> /dev/null
docker rm dev-mongo-container &> /dev/null