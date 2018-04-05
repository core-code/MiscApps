#! /bin/sh

cd "`dirname "$0"`"

if [ -d "Sparkle.framework/Versions/A/Resources/" ];
then
	cd "Sparkle.framework/Versions/A/Resources/"
	rm -rf fr_CA.lproj
	ln -s fr.lproj fr_CA.lproj
	rm -rf pt.lproj
	ln -s pt_BR.lproj pt.lproj
fi;
		
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

		FILEOUTPUT=$(file Versions/Current/"${dir/.framework/}"|grep "i386\|ppc\|ppc64")
		if [[ ! -z  $FILEOUTPUT  ]] 
		 then
			for i in {2..20}
			do
				echo "ERROR: framework has non x86_64 architecture"
			done				
			exit 1
		 fi

		cd ..
	fi;
done;