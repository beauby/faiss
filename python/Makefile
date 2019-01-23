# Copyright (c) 2015-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD+Patents license found in the
# LICENSE file in the root directory of this source tree.

-include ../makefile.inc

HEADERS = $(wildcard ../*.h)

ifneq ($(strip $(NVCC)),)
	SWIGFLAGS = -DGPU_WRAPPER
endif

all: build

# Also silently generates swigfaiss_wrap.py.
swigfaiss_wrap.cpp: swigfaiss.swig $(HEADERS)
	$(SWIG) -python -c++ -Doverride= -I../ $(SWIGFLAGS) -o $@ $<

swigfaiss_wrap.o: swigfaiss_wrap.cpp
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(CPUFLAGS) $(PYTHONCFLAGS) \
               -I../ -c $< -o $@

# Extension is .so even on OSX.
_swigfaiss.so: swigfaiss_wrap.o ../libfaiss.a
	$(CXX) $(SHAREDFLAGS) $(LDFLAGS) -o $@ $^ $(LIBS)

build: _swigfaiss.so swigfaiss.py faiss.py
	$(PYTHON) setup.py build

install: build
	$(PYTHON) setup.py install

clean:
	rm -f swigfaiss_wrap.cpp
	rm -f swigfaiss.py
	rm -f _swigfaiss.so
	rm -rf build/

.PHONY: all build clean install
