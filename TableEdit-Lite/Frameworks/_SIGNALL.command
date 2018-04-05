#! /bin/sh

cd "`dirname "$0"`"
for dir in *
do
	if [ -d $dir ];
	then
		cd $dir

		codesign --verbose --force --sign "Developer ID Application" .

		cd ..
	fi;
done;