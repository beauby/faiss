# Copyright (c) 2015-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD+Patents license found in the
# LICENSE file in the root directory of this source tree.

-include makefile.inc

SRC        = $(wildcard *.cpp)
GPU_CPPSRC = $(wildcard gpu/*.cpp) $(wildcard gpu/impl/*.cpp) \
             $(wildcard gpu/utils/*.cpp)
GPU_CUSRC  = $(wildcard gpu/*.cu) $(wildcard gpu/impl/*.cu) \
             $(wildcard gpu/utils/**/*.cu)
OBJ        = $(SRC:.cpp=.o)
GPU_CPPOBJ = $(GPU_CPPSRC:.cpp=.o)
GPU_CUOBJ  = $(GPU_CUSRC:.cu=.o)

ifneq ($(strip $(NVCC)),)
	OBJ += $(GPU_CPPOBJ) $(GPU_CUOBJ)
endif

############################
# Building

all: libfaiss.a libfaiss.$(SHAREDEXT)

libfaiss.a: $(OBJ)
	ar r $@ $^

libfaiss.$(SHAREDEXT): $(OBJ)
	$(CXX) $(SHAREDFLAGS) $(LDFLAGS) -o $@ $^ $(LIBS)

%.o: %.cpp
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(CPUFLAGS) -c $< -o $@

%.o: %.cu
	$(NVCC) $(NVCCFLAGS) -g -O3 -c $< -o $@

clean:
	rm -f libfaiss.{a,$(SHAREDEXT)}
	rm -f $(OBJ)


############################
# Installing

install: libfaiss.a libfaiss.$(SHAREDEXT) installdirs
	cp libfaiss.a libfaiss.$(SHAREDEXT) $(DESTDIR)$(libdir)
	cp *.h $(DESTDIR)$(includedir)/faiss/
	ifneq ($(strip $(NVCC)),)
		cp gpu/*.h $(DESTDIR)$(includedir)/faiss/gpu/
		cp gpu/impl/*.h $(DESTDIR)$(includedir)/faiss/gpu/impl/
		cp gpu/utils/*.h $(DESTDIR)$(includedir)/faiss/gpu/utils/
	endif

installdirs:
	$(MKDIR_P) $(DESTDIR)$(libdir) $(DESTDIR)$(includedir)/faiss
	ifneq ($(strip $(NVCC)),)
		$(MKDIR_P) $(DESTDIR)$(includedir)/faiss/gpu/{impl,utils}
	endif

uninstall:
	rm -f $(DESTDIR)$(libdir)/libfaiss.{a,$(SHAREDEXT)}
	rm -rf $(DESTDIR)$(includedir)/faiss


#############################
# Dependencies

-include depend

depend: $(SRC) $(GPU_CPPSRC) $(GPU_CUSRC)
	for i in $^; do \
		$(CXXCPP) $(CPPFLAGS) -x c++ -MM $$i; \
	done > depend


#############################
# Tests

test: libfaiss.a py
	make -C tests run
	PYTHONPATH=./python/build/`ls python/build | grep lib` \
	$(PYTHON) -m unittest discover tests/ -v


#############################
# Demos

demos: libfaiss.a
	make -C demos


#############################
# Misc

misc/test_blas: misc/test_blas.cpp
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(LDFLAGS) -o $@ $^ $(LIBS)


#############################
# Python

py:
	$(MAKE) -C python


.PHONY: all clean demos install installdirs py test uninstall
