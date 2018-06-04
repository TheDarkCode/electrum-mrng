#!/bin/bash

# You probably need to update only this link
ELECTRUM_GIT_URL=https://github.com/MorningStarDev/electrum-mrng
BRANCH=master
NAME_ROOT=electrum-mrng


# These settings probably don't need any change
export WINEPREFIX=~/wine64

PYHOME=c:/python27
PYTHON="wine $PYHOME/python.exe -OO -B"


# Let's begin!
cd `dirname $0`
set -e

cd tmp

if [ -d "electrum-mrng" ]; then
    # GIT repository found, update it
    echo "Pull"
    cd electrum-mrng
    git pull
    git checkout $BRANCH
    cd ..
else
    # GIT repository not found, clone it
    echo "Clone"
    git clone -b $BRANCH $ELECTRUM_GIT_URL electrum-mrng
fi

cd electrum-mrng
VERSION=2.9.3.1.3
echo "Last commit: $VERSION"

cd ..

rm -rf $WINEPREFIX/drive_c/electrum-mrng
cp -r electrum-mrng $WINEPREFIX/drive_c/electrum-mrng
#cp electrum-mrng-git/LICENCE .

# add python packages (built with make_packages)
cp -r ../../../packages $WINEPREFIX/drive_c/electrum-mrng/

# add locale dir
#cp -r ../../../lib/locale $WINEPREFIX/drive_c/electrum-mrng/lib/

# Build Qt resources
wine $WINEPREFIX/drive_c/Python27/Lib/site-packages/PyQt4/pyrcc4.exe C:/electrum-mrng/icons.qrc -o C:/electrum-mrng/lib/icons_rc.py
wine $WINEPREFIX/drive_c/Python27/Lib/site-packages/PyQt4/pyrcc4.exe C:/electrum-mrng/icons.qrc -o C:/electrum-mrng/gui/qt/icons_rc.py

cd ..

rm -rf dist/

# build standalone version
$PYTHON "C:/pyinstaller/pyinstaller.py" --noconfirm --ascii --name $NAME_ROOT-$VERSION.exe -w deterministic.spec

# build NSIS installer
# $VERSION could be passed to the electrum.nsi script, but this would require some rewriting in the script iself.
wine "$WINEPREFIX/drive_c/Program Files (x86)/NSIS/makensis.exe" /DPRODUCT_VERSION=$VERSION electrum.nsi

cd dist
mv electrum-mrng-setup.exe $NAME_ROOT-$VERSION-setup.exe
cd ..

# build portable version
cp portable.patch $WINEPREFIX/drive_c/electrum-mrng
pushd $WINEPREFIX/drive_c/electrum-mrng
patch < portable.patch
popd
$PYTHON "C:/pyinstaller/pyinstaller.py" --noconfirm --ascii --name $NAME_ROOT-$VERSION-portable.exe -w deterministic.spec

echo "Done."
