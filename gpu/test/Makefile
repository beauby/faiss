# Copyright (c) 2015-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD+Patents license found in the
# LICENSE file in the root directory of this source tree.

-include ../../makefile.inc

TESTS_SRC = $(wildcard Test*.cpp)
TESTS_OBJ = $(TESTS_SRC:.cpp=.o)
TESTS_BIN = $(TESTS_SRC:.cpp=)


run: $(TESTS_BIN)
	for t in $(TESTS_BIN); do $$t; done

%.o: %.cpp gtest
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(CPUFLAGS) -o $@ -c $< -Igtest/include

%: %.o ../../libfaiss.a gtest/make/gtest.a
	$(CXX) -o $@ $^ $(LDFLAGS) $(LIBS)

demo_ivfpq_indexing_gpu: demo_ivfpq_indexing_gpu.o ../../libfaiss.a
	$(CXX) -o $@ $^ $(LDFLAGS) $(LIBS)

demo_ivfpq_indexing_gpu.o: demo_ivfpq_indexing_gpu.cpp
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(CPUFLAGS) -o $@ -c $^

gtest/make/gtest.a: gtest
	$(MAKE) -C gtest/make CXX="$(CXX)" CXXFLAGS="$(CXXFLAGS)" gtest.a

gtest:
	curl -L https://github.com/google/googletest/archive/release-1.8.0.tar.gz | tar xz && \
	mv googletest-release-1.8.0/googletest gtest && \
	rm -rf googletest-release-1.8.0

clean:
	rm -f *.o $(TESTS_BIN)
	rm -rf gtest
	rm -f demo_ivfpq_indexing_gpu

.PHONY: clean
