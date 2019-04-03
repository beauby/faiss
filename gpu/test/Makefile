# Copyright (c) 2015-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD+Patents license found in the
# LICENSE file in the root directory of this source tree.

-include ../../makefile.inc

%.o: %.cpp
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(CPUFLAGS) -o $@ -c $^

demo_ivfpq_indexing_gpu: demo_ivfpq_indexing_gpu.o ../../libfaiss.a
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(CPUFLAGS) $(LDFLAGS) -o $@ $^ $(LIBS)

clean:
	rm -f *.o demo_ivfpq_indexing_gpu

.PHONY: clean
