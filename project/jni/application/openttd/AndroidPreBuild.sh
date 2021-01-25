#!/bin/sh

mkdir -p build-tools
[ -e build-tools/Makefile ] || cmake -DOPTION_TOOLS_ONLY=ON -B build-tools src || exit 1
make -C build-tools -j8 VERBOSE=1 || exit 1
