#!/bin/sh
git clone --depth=1 https://chromium.googlesource.com/chromium/tools/depot_tools.git
cd depot_tools
git checkout 39bc04eb9f4fbbd05ae68894cc7e1fdbbe17484e
cd ..
export DEPOT_TOOLS_DIR=$PWD/depot_tools
export PATH=$DEPOT_TOOLS_DIR:$DEPOT_TOOLS_DIR/python2_bin:$DEPOT_TOOLS_DIR/python_bin:$PATH
echo "$DEPOT_TOOLS_DIR" >> $GITHUB_PATH
echo "$DEPOT_TOOLS_DIR/python2_bin" >> $GITHUB_PATH
echo "$DEPOT_TOOLS_DIR/python_bin" >> $GITHUB_PATH
