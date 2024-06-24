#!/bin/sh
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
export DEPOT_TOOLS_DIR=$PWD/depot_tools
cd $DEPOT_TOOLS_DIR
git checkout 39bc04eb
export PATH=$DEPOT_TOOLS_DIR:$DEPOT_TOOLS_DIR/python2_bin:$DEPOT_TOOLS_DIR/python_bin:$PATH
echo "$DEPOT_TOOLS_DIR" >> $GITHUB_PATH
echo "$DEPOT_TOOLS_DIR/python2_bin" >> $GITHUB_PATH
echo "$DEPOT_TOOLS_DIR/python_bin" >> $GITHUB_PATH
