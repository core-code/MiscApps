#! /bin/sh

trap 'xcodebuild clean' EXIT
cd "$(dirname "$0")" || exit

xcodebuild install DSTROOT=/
