cp -vaRf ../../../Release/Scrite.app .
cp -vaf ../../Info.plist Scrite.app/Contents
~/Qt/5.15.16/clang_64/bin/macdeployqt Scrite.app -qmldir=../../qml -verbose=1 -appstore-compliant -hardened-runtime

