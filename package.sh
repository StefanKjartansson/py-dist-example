#!/bin/bash

PYTHON_VERSION=${PYTHON_VERSION:=2}
VERSION=${VERSION:=0.0.1}
NAME=${NAME:=${PWD##*/}} # defaults to name of current directory
PREFIX=${PREFIX:=/opt/apps}
DOCKER_FILE=pkg/package.py"$PYTHON_VERSION".docker
DOCKER_IMAGE=package-"$NAME"

if [ ! -f "$DOCKER_FILE" ]; then
    echo "Dockerfile $DOCKER_FILE not found!"
    exit 1
fi

docker build \
    -t "$DOCKER_IMAGE" \
    -f "$DOCKER_FILE" .

docker run \
    -e NAME="$NAME" \
    -e VERSION="$VERSION" \
    -e PREFIX="$PREFIX"/"$NAME" \
    -v "$PWD"/dist:/dist \
    "$DOCKER_IMAGE"
