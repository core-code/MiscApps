#! /bin/sh

cd "`dirname "$0"`"

echo "Type the TAG that you want to use (x.y.z) followed by [ENTER]:"

read newtagnumber

git tag -a $newtagnumber -m "tag $newtagnumber"
git push origin $newtagnumber
