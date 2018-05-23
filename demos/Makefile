# Copyright (c) 2015-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD+Patents license found in the
# LICENSE file in the root directory of this source tree.

DEMOS_SRC=$(wildcard demo_*.cpp)
DEMOS=$(DEMOS_SRC:.cpp=)

all: $(DEMOS)

clean:
	rm -f $(DEMOS)

%: %.cpp ../libfaiss.a
	$(CXX) -o $@ $(CXXFLAGS) $^ $(LDFLAGS) $(LIBS)

.SUFFIXES: .cpp .o
.PHONY: all clean
