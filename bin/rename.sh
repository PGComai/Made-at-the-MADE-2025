#!/bin/bash
set -e

cd "$(dirname "$0")"

mv linux/offroad_legacy.zip linux-offroad_legacy.zip
mv macos/offroad_legacy.zip macos-offroad_legacy.zip
mv windows/offroad_legacy.zip windows-offroad_legacy.zip

cd web
zip web.zip * -x ".gitignore"
mv web.zip ../web.zip
