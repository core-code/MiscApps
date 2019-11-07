#! /bin/sh

cd "`dirname "$0"`"


for file in *
do
	if [ -d "${file}" ]; then
		cd "${file}"
		git gc --prune=now --aggressive
		cd ..
	fi
done

