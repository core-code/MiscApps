#! /bin/sh

if [ ! -d "$CC_APP_PATH" ] || [ ! -d "$CC_WEB_PATH" ]; then
	echo "\n\nERROR: CC_APP_PATH or CC_WEB_PATH environment variable not properly set\n\n"
  	exit 1
fi


textutil -convert html "$CC_APP_PATH/_OPENSOURCE/MailSpy/MailSpy/FAQ.rtf" -output "$CC_WEB_PATH/corecode.io/mailspy/faq.html"

textutil -convert html "$CC_APP_PATH/_OPENSOURCE/MailSpy/MailSpy/History.rtf" -output "$CC_WEB_PATH/corecode.io/mailspy/history.html"

textutil -convert html "$CC_APP_PATH/_OPENSOURCE/MailSpy/MailSpy/Read Me.rtf" -output "$CC_WEB_PATH/corecode.io/mailspy/readme.html"

websiteProcessReadMe.py "$CC_WEB_PATH/corecode.io/mailspy/readme.html"
websiteProcessIndexHTML.py "$CC_WEB_PATH/corecode.io/mailspy/readme.html" "$CC_WEB_PATH/corecode.io/mailspy/index.html"

