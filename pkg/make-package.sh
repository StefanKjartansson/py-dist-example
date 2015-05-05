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

# support python3, virtualenv command has
# been moved to venv module
ret=$(python -c 'import sys; print("%i" % (sys.hexversion<0x03000000))')
if [ "$ret" -eq 0 ]; then
    python -m venv env
else
    virtualenv env
fi

./env/bin/pip install --no-index --find-links=/tmp/wheelhouse -r requirements.txt

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
