#! /bin/sh

cd "`dirname "$0"`"
for dir in *
do
	if [ -d $dir ];
	then
		cd $dir
		echo $dir
		echo "${dir/.framework/}"
		ls -la
		rm -rf Headers
		rm -rf PrivateHeaders
		rm -rf Resources
		rm -rf XPCServices
		rm -rf Modules
		rm -rf Versions/Current
		rm -rf "${dir/.framework/}"

		cd Versions
		ln -s A Current
		cd ..


		ln -s Versions/Current/"${dir/.framework/}" "${dir/.framework/}"

		if [ -d Versions/Current/PrivateHeaders ];
		then
			ln -s Versions/Current/PrivateHeaders PrivateHeaders
		fi;
		if [ -d Versions/Current/Headers ];
		then
			ln -s Versions/Current/Headers Headers
		fi;
		if [ -d Versions/Current/Resources ];
		then
			ln -s Versions/Current/Resources Resources
		fi;
		if [ -d Versions/Current/XPCServices ];
		then
			ln -s Versions/Current/XPCServices XPCServices
		fi;	
		if [ -d Versions/Current/Modules ];
		then
			ln -s Versions/Current/Modules Modules
		fi;	

		cd ..
	fi;
done;