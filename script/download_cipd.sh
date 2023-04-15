#!/bin/sh
git clone --depth 1 "https://github.com/wankaiming/dependencies.git" .cipd
cp .cipd/.gclient .
cp .cipd/.gclient_entries .
