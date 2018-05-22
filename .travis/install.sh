#!/bin/bash

if [[ $TRAVIS_OS_NAME == 'osx' ]]; then
    cp example_makefiles/makefile.inc.Mac.brew ./makefile.inc
    # TODO: Test MacPorts-based makefile.inc.
elif [[ $TRAVIS_OS_NAME == 'linux' ]]; then
    cp example_makefiles/makefile.inc.Linux ./makefile.inc
fi

make # && make install
