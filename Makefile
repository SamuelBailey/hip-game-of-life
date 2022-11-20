# Copyright (C) 2022 Samuel Bailey

HIPIFY=hipify-clang
CXX=hipcc

CXX_FLAGS = -O0 -std=c++17 -Wno-unused-value -ggdb -fgpu-rdc 
LINKER_FLAGS = -fgpu-rdc --hip-link

HEADERS = $(wildcard *.h)


%.hip: %.cu $(HEADERS)
	$(HIPIFY) -o $@ $<

%.o: %.hip $(HEADERS)
	$(CXX) -c -o $@ $< $(CXX_FLAGS)

%.o: %.cpp $(HEADERS)
	$(CXX) -c -o $@ $< $(CXX_FLAGS)

CU_FILES = $(wildcard *.cu)
HIP_FILES = $(CU_FILES:.cu=.hip)
CPP_FILES = $(wildcard *.cpp)
OBJS = $(HIP_FILES:.hip=.o) $(CPP_FILES:.cpp=.o)

life: $(OBJS)
	$(CXX) -o $@ $^ $(LINKER_FLAGS)

clean:
	rm $(OBJS) life test $(TEST_OBJS)

# UNIT Tests!! Type `make test`

TEST_HEADERS = $(wildcard tests/*.h) $(wildcard tests/*.hpp)
TEST_CPPS = $(wildcard tests/*.cpp)
TEST_OBJS = $(TEST_CPPS:.cpp=.o)

OBJS_NO_MAIN = $(filter-out main.o,$(OBJS))

test: $(TEST_OBJS) $(OBJS_NO_MAIN)
	$(CXX) -o $@ $^
