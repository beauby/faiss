#!/bin/bash

if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then
    true # Do nothing
elif [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    true # Do nothing
fi
