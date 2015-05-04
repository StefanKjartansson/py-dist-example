#!/bin/bash
set -e

NAME=${NAME:=name}
VERSION=${VERSION:=0.0.1}
PREFIX=${PREFIX:=/usr/bin}
ARCH=$(uname -m)
DATE=$(date +"%s")

APP_PATH="$PREFIX"/"$VERSION"
#BUILD=$(pwd)/"$NAME"-"$VERSION"
#PPATH="$BUILD""$PREFIX"/"$NAME"

mkdir -p "$APP_PATH"

echo "git archive --format=tar --prefix=$APP_PATH/ HEAD"
git archive --format=tar --prefix="$APP_PATH"/ HEAD | (cd "$APP_PATH" && tar xf -)

pushd "$APP_PATH"

echo "$pwd"

ls

virtualenv env
. env/bin/activate
pip install -r requirements.txt

popd

fpm \
    -s dir \
    -t rpm \
    --epoch "$DATE" \
    -v "$VERSION" \
    -n "$NAME" \
    -a "$ARCH" \
    .

fpm \
    -s dir \
    -t deb \
    --epoch "$DATE" \
    -v "$VERSION" \
    -n "$NAME" \
    -a "$ARCH" \
    .

mv ./*.rpm /dist/
mv ./*.deb /dist/
