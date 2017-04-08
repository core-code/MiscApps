#! /bin/sh

cd "`dirname "$0"`"

			
for file in "CHMExtractor" "CoreLS" "DesktopLyrics-Lite" "FilenameList" "FingerFrag" "FingerMaze" "FlowCore" "InstaCode" "iOmniMap" "iRipCD" "iRipDVD" "KeyPresser" "LayoutTest" "Leaker" "MacEVO" "MailboxAlert" "MailSpy" "MenuSwitch" "MountMenu"  "MovieDB" "MusicWatch" "OmniExpose" "PDFullscreen" "Phorgiveness" "QTPresenter" "ReadingListPro" "SecondRow" "SelectionFlasher" "SMARTReporter-Lite" "SMARTReporterFactoryReset" "SpotifyAdBlocker" "STOCKings" "TerraCore" "TimerMenu" "Translator" "TunesControllerClient" "TunesControllerServer" "Updater" "VolumeCore" "WindowMover" "WindowTiler" "XMPV" "Diagnostics/CoreCodeDiagnosisTool" "Diagnostics/SMARTReporterDiagnosisTool" "Diagnostics/UninstallPKGDiagnosisTool" "Diagnostics/VersionsManagerDiagnosisTool"
do
	cd "${file}"
	echo "${file}"
	xcodebuild -configuration Debug clean |grep -i '\*\*'
	xcodebuild -configuration Debug build |grep -i '\*\*'
	xcodebuild -configuration Debug clean |grep -i '\*\*'
	rm -rf "build/"
	cd "`dirname "$0"`"
done
