#!/bin/bash

if [[ $TRAVIS_OS_NAME == 'osx' ]]; then
    brew install llvm
fi
