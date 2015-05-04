#!/bin/bash
set -e

NAME=${NAME:=name}
VERSION=${VERSION:=0.0.1}
PREFIX=${PREFIX:=/usr/bin}
BUILD_DIR=$(pwd)
ARCH=$(uname -m)
DATE=$(date +"%s")

APP_PATH="$PREFIX"/"$VERSION"
mkdir -p "$APP_PATH"
cp -r . "$APP_PATH"

cd "$APP_PATH"

virtualenv env
. env/bin/activate
pip install --no-index --find-links=/tmp/wheelhouse -r requirements.txt

rm -rf {.gitignore,.dockerignore,pkg,.git,./*package.sh}

cd "$BUILD_DIR"

packages=( deb rpm )
for i in "${packages[@]}"
do
    fpm \
        -s dir \
        -t "$i" \
        --prefix "$APP_PATH" \
        --epoch "$DATE" \
        -v "$VERSION" \
        -n "$NAME" \
        -a "$ARCH" \
        -C "$APP_PATH" \
        .
    mv ./*."$i" /dist/
done
