#! /bin/sh

cd "`dirname "$0"`"


codesign --verbose --force --sign "Developer ID Application" org.sparkle-project.InstallerLauncher.xpc/Contents/MacOS/Autoupdate
codesign --verbose --force --sign "Developer ID Application" org.sparkle-project.InstallerLauncher.xpc/Contents/MacOS/Updater.app
codesign --verbose --force --sign "Developer ID Application" org.sparkle-project.InstallerLauncher.xpc
codesign --verbose --force --sign "Developer ID Application" org.sparkle-project.Downloader.xpc
codesign --verbose --force --sign "Developer ID Application" org.sparkle-project.InstallerConnection.xpc
codesign --verbose --force --sign "Developer ID Application" org.sparkle-project.InstallerStatus.xpc
