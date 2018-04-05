#! /bin/sh

if [ ! -d "$CC_APP_PATH" ] || [ ! -d "$CC_WEB_PATH" ]; then
	echo "\n\nERROR: CC_APP_PATH or CC_WEB_PATH environment variable not properly set\n\n"
  	exit 1
fi


cp "$CC_APP_PATH/../MiscApps/TableEdit-Lite/TableEdit/faq.html" "$CC_WEB_PATH/corecode.io/tableedit_lite/faq.html"
cp "$CC_APP_PATH/../MiscApps/TableEdit-Lite/TableEdit/history.html" "$CC_WEB_PATH/corecode.io/tableedit_lite/history.html"
cp "$CC_APP_PATH/../MiscApps/TableEdit-Lite/TableEdit/readme.html" "$CC_WEB_PATH/corecode.io/tableedit_lite/readme.html"

websiteProcessReadMe.py "$CC_WEB_PATH/corecode.io/tableedit_lite/readme.html"
websiteProcessIndexHTML.py "$CC_WEB_PATH/corecode.io/tableedit_lite/readme.html" "$CC_WEB_PATH/corecode.io/tableedit_lite/index.html"

